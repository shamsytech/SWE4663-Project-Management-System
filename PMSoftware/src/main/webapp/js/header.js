document.addEventListener("DOMContentLoaded", () => {
  fetch("../components/header.html")
    .then(response => response.text())
    .then(html => {
      const placeholder = document.getElementById("header-placeholder");
      if (!placeholder) return;
      placeholder.innerHTML = html;

      // 🔁 Re-execute scripts inside loaded header
      const scripts = placeholder.querySelectorAll("script");
      scripts.forEach((oldScript) => {
        const newScript = document.createElement("script");
        if (oldScript.src) {
          newScript.src = oldScript.src;
        } else {
          newScript.textContent = oldScript.textContent;
        }
        document.body.appendChild(newScript);
      });

      // ✅ Sidebar toggle logic after header loads
      const sidebar = document.getElementById("sidebar");
      const openBtn = document.querySelector(".menu-btn");
      const closeBtn = document.querySelector(".close-sidebar-btn");

      if (openBtn && sidebar) {
        openBtn.addEventListener("click", () => {
          sidebar.classList.add("show");
          document.body.classList.add("sidebar-open");
        });
      }

      if (closeBtn && sidebar) {
        closeBtn.addEventListener("click", () => {
          sidebar.classList.remove("show");
          document.body.classList.remove("sidebar-open");
        });
      }

      // Dynamic page title
      const title = document.body.getAttribute("data-title");
      const titleEl = document.getElementById("dynamic-page-title");
      if (title && titleEl) titleEl.textContent = title;

      // Dynamic avatar
      const avatar = document.body.getAttribute("data-avatar");
      const avatarEl = document.getElementById("user-avatar");
      if (avatar && avatarEl) avatarEl.src = avatar;

      // Dynamic user name and email
      const userName = document.body.getAttribute("data-user-name");
      const userEmail = document.body.getAttribute("data-user-email");

      const nameEl = document.getElementById("sidebar-user-name");
      const emailEl = document.getElementById("sidebar-user-email");

      if (userName && nameEl) nameEl.textContent = `Hello ${userName}`;
      if (userEmail && emailEl) emailEl.textContent = userEmail;
    })
    .catch(err => console.error("Failed to load header:", err));
});
