// app.js
// Smooth scroll navigation and highlight active section

document.addEventListener('DOMContentLoaded', function () {
  // Smooth scroll for nav links
  document.querySelectorAll('.nu-header nav a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      e.preventDefault();
      const target = document.querySelector(this.getAttribute('href'));
      if (target) {
        window.scrollTo({
          top: target.offsetTop - 62,
          behavior: 'smooth'
        });
      }
    });
  });

  // Highlight active nav link on scroll
  const sections = Array.from(document.querySelectorAll('main section'));
  const navLinks = Array.from(document.querySelectorAll('.nu-header nav a[href^="#"]'));

  function onScroll() {
    const scrollPos = window.scrollY + 70;
    let found = false;
    for (let i = sections.length - 1; i >= 0; i--) {
      if (scrollPos >= sections[i].offsetTop) {
        navLinks.forEach(link => link.classList.remove('active'));
        const id = sections[i].getAttribute('id');
        const activeLink = navLinks.find(link => link.getAttribute('href') === '#' + id);
        if (activeLink) activeLink.classList.add('active');
        found = true;
        break;
      }
    }
    if (!found) navLinks.forEach(link => link.classList.remove('active'));
  }
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();
});
