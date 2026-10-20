"use strict";

// =====================================
// API CONFIGURATION
// =====================================
const API_BASE = "../api"; 

async function apiCall(path, options = {}) {
  const res = await fetch(API_BASE + path, {
    credentials: "include", // Required for sessions
    ...options,
  });
  return res.json();
}

function showToast(message, type = "") {
  const toast = document.getElementById("toast");
  toast.textContent = message;
  toast.className = `toast show ${type}`;
  setTimeout(() => { toast.classList.remove("show"); }, 3000);
}

// =====================================
// HELPER FUNCTIONS
// =====================================
const getElement = (id) => document.getElementById(id);

function setText(id, value) {
  getElement(id).textContent =
    value === undefined || value === null || value === ""
      ? "Not available"
      : String(value);
}

function showPage(pageId) {
  ["loginPage", "registerPage", "dashboardPage"].forEach((id) => {
    getElement(id).classList.add("hidden");
  });
  getElement(pageId).classList.remove("hidden");
}

function formatDate(dateString) {
  if (!dateString) return "Not available";
  const parts = dateString.split("-");
  if (parts.length !== 3) return dateString;
  const date = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
  return date.toLocaleDateString("en-PH", { year: "numeric", month: "short", day: "numeric" });
}

// =====================================
// NAVIGATION
// =====================================
getElement("showRegister").addEventListener("click", () => {
  getElement("registerForm").reset();
  getElement("registerMessage").textContent = "";
  showPage("registerPage");
});

getElement("showLogin").addEventListener("click", () => {
  getElement("loginError").textContent = "";
  showPage("loginPage");
});

// =====================================
// AUTHENTICATION (LOGIN / REGISTER)
// =====================================
getElement("registerForm").addEventListener("submit", async (event) => {
  event.preventDefault();
  const fullName = getElement("registerFullName").value.trim();
  const email = getElement("registerEmail").value.trim();
  const password = getElement("registerPassword").value;
  const message = getElement("registerMessage");

  message.textContent = "";
  if (!fullName || !email || !password) {
    message.textContent = "Please complete all fields.";
    message.className = "message error";
    return;
  }

  try {
    const data = await apiCall("/auth/register.php", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ full_name: fullName, email: email, password: password })
    });

    if (data.ok) {
      message.textContent = "Account created! Redirecting to login...";
      message.className = "message success";
      
      // Pre-fill the email on the login screen for convenience
      getElement("loginEmail").value = email;

      setTimeout(() => {
        getElement("registerForm").reset();
        message.textContent = "";
        showPage("loginPage");
      }, 1500);
    } else {
      message.textContent = data.error || "Registration failed.";
      message.className = "message error";
    }
  } catch (err) {
    message.textContent = "Network error. Try again.";
    message.className = "message error";
  }
});

getElement("loginForm").addEventListener("submit", async (event) => {
  event.preventDefault();
  const email = getElement("loginEmail").value.trim();
  const password = getElement("loginPassword").value;
  const loginError = getElement("loginError");
  loginError.textContent = "";

  try {
    const data = await apiCall("/auth/login.php", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: email, password: password })
    });

    if (data.ok) {
      getElement("loginForm").reset();
      openDashboard(data.user);
    } else {
      loginError.textContent = "Incorrect email or password.";
    }
  } catch (err) {
    loginError.textContent = "Network error. Try again.";
  }
});

getElement("logoutBtn").addEventListener("click", async () => {
  await apiCall("/auth/logout.php", { method: "POST" });
  getElement("loginForm").reset();
  getElement("loginError").textContent = "";
  getElement("searchInput").value = "";
  closeDetails();
  showPage("loginPage");
});

// =====================================
// DASHBOARD & STATS
// =====================================
async function openDashboard(user) {
  showPage("dashboardPage");
  setText("welcomeUser", `Welcome, ${user.full_name}`);
  setText("todayDate", new Date().toLocaleDateString("en-PH", { year: "numeric", month: "long", day: "numeric" }));
  setText("currentYear", new Date().getFullYear());

  // Show admin panel if user is admin
  if (user.role === "admin") {
    getElement("adminPanel").classList.remove("hidden");
  } else {
    getElement("adminPanel").classList.add("hidden");
  }

  loadStats();
  searchRecords(); // Load all records initially
}

async function loadStats() {
  try {
    const data = await apiCall("/dashboard/stats.php");
    if (data.ok) {
      setText("totalRecords", data.total_records);
      setText("searchableRecords", data.searchable);
      setText("totalLocations", data.locations);
    }
  } catch (err) {
    console.error("Failed to load stats", err);
  }
}

// =====================================
// SEARCH & TABLE DISPLAY
// =====================================
async function searchRecords() {
  const query = getElement("searchInput").value.trim();
  
  // Default to name search if they type something, or show all if empty
  const type = query === "" ? "name" : (query.includes("RIP-") ? "id" : "name");
  
  // Our API requires at least 2 chars. If empty, we fetch everything via a wildcard.
  let body = { query: query, type: type };
  if (query === "") {
    body = { query: "%%", type: "name" }; 
  }

  try {
    const data = await apiCall("/graves/search.php", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body)
    });

    if (data.ok) {
      displayRecords(data.results);
    } else {
      if (data.error === "min_2_chars") {
        showToast("Type at least 2 characters to search", "error");
      }
      displayRecords([]);
    }
  } catch (err) {
    showToast("Search failed. Check connection.", "error");
  }
}

function displayRecords(records) {
  const table = getElement("recordsTable");
  const emptyState = getElement("emptyState");
  table.replaceChildren();

  setText("resultCount", `${records.length} record${records.length === 1 ? "" : "s"}`);
  emptyState.classList.toggle("hidden", records.length > 0);

  records.forEach((record) => {
    const row = document.createElement("tr");

    const locationStr = `${record.cemetery} / ${record.section || ""}`;

    const values = [
      { value: record.grave_code, className: "record-id" },
      { value: record.full_name },
      { value: formatDate(record.birth_date) },
      { value: formatDate(record.death_date) },
      { value: locationStr, className: "location-tag" },
    ];

    values.forEach((item) => {
      const cell = document.createElement("td");
      const content = document.createElement("span");
      content.textContent = item.value;
      if (item.className) content.className = item.className;
      cell.appendChild(content);
      row.appendChild(cell);
    });

    const actionCell = document.createElement("td");
    const viewButton = document.createElement("button");
    viewButton.type = "button";
    viewButton.className = "view-btn";
    viewButton.textContent = "View Details";
    viewButton.addEventListener("click", () => showDetails(record.grave_code));

    actionCell.appendChild(viewButton);
    row.appendChild(actionCell);
    table.appendChild(row);
  });
}

getElement("searchBtn").addEventListener("click", searchRecords);

let searchTimeout;
getElement("searchInput").addEventListener("input", () => {
  clearTimeout(searchTimeout);
  searchTimeout = setTimeout(searchRecords, 500); // Debounce
});

getElement("clearBtn").addEventListener("click", () => {
  getElement("searchInput").value = "";
  searchRecords();
  getElement("searchInput").focus();
});

// =====================================
// VIEW FAVORITES
// =====================================
getElement("viewFavoritesBtn").addEventListener("click", async () => {
  getElement("searchInput").value = "";
  
  try {
    const data = await apiCall("/favorites/list.php");
    
    if (data.ok) {
      if (data.count === 0) {
        showToast("You haven't favorited any records yet.", "error");
        displayRecords([]);
      } else {
        showToast(`Showing ${data.count} favorite(s)`, "success");
        
        const formattedRecords = data.results.map(r => ({
          grave_code: r.grave_code,
          full_name: r.full_name,
          birth_date: r.birth_date,
          death_date: r.death_date,
          cemetery: r.cemetery,
          section: "", 
        }));
        
        displayRecords(formattedRecords);
      }
    }
  } catch (err) {
    showToast("Failed to load favorites", "error");
  }
});

// =====================================
// DETAILS MODAL & ACTIONS
// =====================================
let currentGraveCode = null;

async function showDetails(graveCode) {
  currentGraveCode = graveCode;
  try {
    const data = await apiCall(`/graves/get.php?id=${encodeURIComponent(graveCode)}`);
    if (!data.ok) {
      showToast("Failed to load details", "error");
      return;
    }

    const record = data.grave;
    
    let genderStr = "Not available";
    if (record.gender === "M") genderStr = "Male";
    if (record.gender === "F") genderStr = "Female";
    if (record.gender === "O") genderStr = "Other";

    setText("modalName", record.full_name);
    setText("detailId", record.grave_code);
    setText("detailName", record.full_name);
    setText("detailGender", genderStr);
    setText("detailBirth", formatDate(record.birth_date));
    setText("detailDeath", formatDate(record.death_date));
    setText("detailAge", record.age_at_death);
    setText("detailAddress", record.address);
    setText("detailCemetery", record.cemetery);
    setText("detailArea", record.area);
    setText("detailSection", record.section);
    setText("detailPlot", record.plot_number);
    setText("detailBurialDate", formatDate(record.burial_date));
    setText("detailKin", record.next_of_kin);
    setText("detailNotes", record.notes);

    getElement("detailsModal").classList.remove("hidden");
  } catch (err) {
    showToast("Network error while loading details", "error");
  }
}

function closeDetails() {
  getElement("detailsModal").classList.add("hidden");
  currentGraveCode = null;
}

getElement("closeModal").addEventListener("click", closeDetails);
getElement("closeModalBottom").addEventListener("click", closeDetails);
getElement("detailsModal").addEventListener("click", (event) => {
  if (event.target === getElement("detailsModal")) closeDetails();
});
document.addEventListener("keydown", (event) => {
  if (event.key === "Escape" && !getElement("detailsModal").classList.contains("hidden")) closeDetails();
});

getElement("printBtn").addEventListener("click", () => window.print());

// Favorite Button
getElement("favBtn").addEventListener("click", async () => {
  if (!currentGraveCode) return;
  try {
    const data = await apiCall("/favorites/toggle.php", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ grave_code: currentGraveCode })
    });
    if (data.ok) {
      showToast(data.favorited ? "Added to favorites!" : "Removed from favorites", "success");
    }
  } catch (err) {
    showToast("Failed to toggle favorite", "error");
  }
});

// Report Issue Button
getElement("reportBtn").addEventListener("click", async () => {
  if (!currentGraveCode) return;
  const issueType = prompt("Enter issue type (wrong_name, wrong_dates, wrong_location, other):", "wrong_name");
  if (!issueType) return;
  const desc = prompt("Briefly describe the issue:");
  
  try {
    const data = await apiCall("/reports/create.php", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ 
        grave_code: currentGraveCode, 
        issue_type: issueType, 
        description: desc 
      })
    });
    if (data.ok) {
      showToast("Report submitted successfully.", "success");
    } else {
      showToast(`Error: ${data.error}`, "error");
    }
  } catch (err) {
    showToast("Failed to submit report", "error");
  }
});

// =====================================
// ADMIN CSV UPLOAD
// =====================================
getElement("uploadCsvBtn").addEventListener("click", async () => {
  const fileInput = getElement("csvFile");
  if (!fileInput.files.length) {
    showToast("Please select a CSV file first.", "error");
    return;
  }

  const formData = new FormData();
  formData.append("file", fileInput.files[0]);

  const btn = getElement("uploadCsvBtn");
  btn.textContent = "Uploading...";
  btn.disabled = true;

  try {
    const res = await fetch(API_BASE + "/admin/csv_upload.php", {
      method: "POST",
      body: formData,
      credentials: "include"
    });
    const data = await res.json();

    if (data.ok) {
      showToast(`CSV Uploaded! Inserted: ${data.inserted}, Skipped: ${data.skipped}`, "success");
      fileInput.value = ""; // Clear input
      loadStats(); // Refresh stats
      searchRecords(); // Refresh table
    } else {
      showToast(`Error: ${data.error}`, "error");
    }
  } catch (err) {
    showToast("Upload failed.", "error");
  } finally {
    btn.textContent = "Upload CSV";
    btn.disabled = false;
  }
});

// =====================================
// ADMIN MANUAL ADD GRAVE
// =====================================
getElement("openAddGraveBtn").addEventListener("click", () => {
  getElement("addGraveModal").classList.remove("hidden");
});

getElement("closeAddGraveModal").addEventListener("click", () => {
  getElement("addGraveModal").classList.add("hidden");
});

getElement("addGraveForm").addEventListener("submit", async (e) => {
  e.preventDefault();
  const btn = e.target.querySelector("button[type='submit']");
  btn.textContent = "Saving...";
  btn.disabled = true;

  const payload = {
    full_name: getElement("addName").value,
    cemetery_name: getElement("addCemetery").value,
    birth_date: getElement("addBirth").value,
    death_date: getElement("addDeath").value,
    section: getElement("addSection").value,
    plot_number: getElement("addPlot").value
  };

  try {
    const data = await apiCall("/admin/add_grave.php", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });

    if (data.ok) {
      showToast("Grave added successfully!", "success");
      getElement("addGraveForm").reset();
      getElement("addGraveModal").classList.add("hidden");
      loadStats(); 
      searchRecords(); 
    } else {
      showToast(data.error, "error");
    }
  } catch (err) {
    showToast("Failed to add grave.", "error");
  } finally {
    btn.textContent = "Save Record";
    btn.disabled = false;
  }
});

// =====================================
// ON LOAD SESSION CHECK
// =====================================
(async function checkSession() {
  try {
    const data = await apiCall("/auth/me.php");
    if (data.ok) {
      openDashboard(data.user); // Auto login
    } else {
      showPage("loginPage");
    }
  } catch (err) {
    showPage("loginPage");
  }
})();