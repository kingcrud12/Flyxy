const PolitiqueConfidentialite = () => {
  return (
    <div className="fade-in">
      <section className="section" style={{ paddingTop: '140px' }}>
        <div className="container" style={{ maxWidth: '800px' }}>
          <h1 className="heading-hero" style={{ fontSize: '3rem', marginBottom: '48px' }}>Politique de Confidentialité</h1>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '40px' }}>
            <div>
              <h2 className="heading-section" style={{ fontSize: '1.5rem', marginBottom: '12px' }}>1. Collecte des données</h2>
              <p className="subtitle">
                Dans le cadre de l'utilisation de Flyxy, nous sommes amenés à collecter certaines données vous concernant :<br /><br />
                — <strong>Données de compte :</strong> Pseudonyme, email (optionnel selon l'inscription), et mot de passe chiffré.<br />
                — <strong>Données de localisation :</strong> Coordonnées GPS strictement utilisées pour vous afficher les arrêts à proximité.
              </p>
            </div>

            <div>
              <h2 className="heading-section" style={{ fontSize: '1.5rem', marginBottom: '12px' }}>2. Utilisation de la Géolocalisation</h2>
              <p className="subtitle">
                L'application requiert l'accès à votre position géographique en temps réel pour fonctionner correctement
                (recherche des arrêts, calcul d'itinéraires).
                <strong> Votre position n'est jamais sauvegardée sur nos serveurs de manière persistante ni revendue à des tiers.</strong>
                Elle est uniquement envoyée à notre API pour interroger les bases de données de transport autour de vous.
              </p>
            </div>

            <div>
              <h2 className="heading-section" style={{ fontSize: '1.5rem', marginBottom: '12px' }}>3. Réseau Social & Contenu Public</h2>
              <p className="subtitle">
                Lorsque vous publiez un commentaire ou un message (Post) sur le fil d'actualité de Flyxy, ce contenu est
                rendu public et visible par les autres utilisateurs de l'application. Vous êtes responsable du contenu
                que vous partagez.
              </p>
            </div>

            <div>
              <h2 className="heading-section" style={{ fontSize: '1.5rem', marginBottom: '12px' }}>4. Sécurité des Données</h2>
              <p className="subtitle">
                Nous utilisons des protocoles de sécurité avancés : mots de passe hachés (bcrypt), communications chiffrées (HTTPS),
                et sessions gérées par des JSON Web Tokens (JWT) stockés de manière sécurisée (HttpOnly).<br /><br />
                Pour toute demande de suppression de compte ou de données, veuillez nous contacter à{' '}
                <a href="mailto:info@flyxy.fr" style={{ color: 'var(--green)', fontWeight: 600 }}>info@flyxy.fr</a>.
              </p>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default PolitiqueConfidentialite;
