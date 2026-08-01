import { Link } from 'react-router-dom';
import { useState } from 'react';
import logo from '../assets/logo.png';

const Navbar = () => {
  const [menuOpen, setMenuOpen] = useState(false);

  return (
    <header className="site-header">
      <div className="container">
        <div className="nav-inner">
          <Link to="/" className="nav-logo" style={{ gap: '12px' }}>
            <img src={logo} alt="Flyxy logo" style={{ height: '56px', width: 'auto', borderRadius: '12px' }} />
            <span style={{ fontSize: '1.75rem' }}>Flyxy</span>
          </Link>

          <nav className="nav-links">
            <Link to="/">Accueil</Link>
            <Link to="/mentions-legales">Mentions Légales</Link>
            <Link to="/politique-confidentialite">Confidentialité</Link>
            <a href="mailto:info@flyxy.fr">Contact</a>
            <a href="#download" className="nav-cta">Télécharger</a>
          </nav>

          <button
            className={`nav-hamburger ${menuOpen ? 'active' : ''}`}
            onClick={() => setMenuOpen(!menuOpen)}
            aria-label="Menu"
          >
            <span></span>
            <span></span>
            <span></span>
          </button>
        </div>

        {menuOpen && (
          <nav className="nav-mobile-menu">
            <Link to="/" onClick={() => setMenuOpen(false)}>Accueil</Link>
            <Link to="/mentions-legales" onClick={() => setMenuOpen(false)}>Mentions Légales</Link>
            <Link to="/politique-confidentialite" onClick={() => setMenuOpen(false)}>Confidentialité</Link>
            <a href="mailto:info@flyxy.fr" onClick={() => setMenuOpen(false)}>Contact</a>
            <a href="#download" className="nav-cta" onClick={() => setMenuOpen(false)}>Télécharger</a>
          </nav>
        )}
      </div>
    </header>
  );
};

export default Navbar;
