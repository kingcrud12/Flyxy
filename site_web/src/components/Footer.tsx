import { Link } from 'react-router-dom';

const Footer = () => {
  return (
    <footer className="site-footer">
      <div className="container">
        <div className="footer-grid">
          <div>
            <div className="footer-logo">Flyxy</div>
            <p className="footer-desc">
              L'application de transport en commun pensée pour l'Île-de-France.
              Horaires en temps réel, recherche vocale et communauté de voyageurs.
            </p>
          </div>

          <div className="footer-col">
            <h4>Application</h4>
            <Link to="/">Accueil</Link>
            <a href="mailto:info@flyxy.fr">Contact</a>
          </div>

          <div className="footer-col">
            <h4>Légal</h4>
            <Link to="/mentions-legales">Mentions Légales</Link>
            <Link to="/politique-confidentialite">Politique de Confidentialité</Link>
          </div>
        </div>

        <div className="footer-bottom">
          © {new Date().getFullYear()} Flyxy. Tous droits réservés. — info@flyxy.fr
        </div>
      </div>
    </footer>
  );
};

export default Footer;
