const MentionsLegales = () => {
  return (
    <div className="fade-in">
      <section className="section" style={{ paddingTop: '140px' }}>
        <div className="container" style={{ maxWidth: '800px' }}>
          <h1 className="heading-hero" style={{ fontSize: '3rem', marginBottom: '48px' }}>Mentions Légales</h1>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '40px' }}>
            <div>
              <h2 className="heading-section" style={{ fontSize: '1.5rem', marginBottom: '12px' }}>1. Éditeur de l'application</h2>
              <p className="subtitle">
                L'application Flyxy et le site web associé sont édités par l'équipe Flyxy.<br />
                Email de contact : <a href="mailto:info@flyxy.fr" style={{ color: 'var(--green)', fontWeight: 600 }}>info@flyxy.fr</a>
              </p>
            </div>

            <div>
              <h2 className="heading-section" style={{ fontSize: '1.5rem', marginBottom: '12px' }}>2. Hébergement</h2>
              <p className="subtitle">
                L'API de l'application et le présent site web sont hébergés sur un Serveur Privé Virtuel (VPS) sécurisé.
                Les bases de données sont gérées en interne et ne sont pas partagées avec des tiers.
              </p>
            </div>

            <div>
              <h2 className="heading-section" style={{ fontSize: '1.5rem', marginBottom: '12px' }}>3. Données Ouvertes (Open Data)</h2>
              <p className="subtitle">
                Les données de transport (horaires, arrêts, trafic) affichées dans l'application proviennent de l'API publique
                PRIM (Plateforme Régionale d'Information sur la Mobilité) gérée par Île-de-France Mobilités / Navitia.
                Flyxy agit en tant que client de ces données afin d'offrir une interface utilisateur améliorée.
              </p>
            </div>

            <div>
              <h2 className="heading-section" style={{ fontSize: '1.5rem', marginBottom: '12px' }}>4. Propriété Intellectuelle</h2>
              <p className="subtitle">
                L'ensemble des éléments graphiques, la structure et, plus généralement, le contenu du site
                et de l'application Flyxy sont protégés par le droit d'auteur, le droit des marques et le
                droit des dessins et modèles. Toute personne qui recueille ou télécharge du contenu ou des
                informations diffusées sur l'application ne dispose sur ceux-ci que d'un droit d'usage privé,
                personnel et non transmissible.
              </p>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default MentionsLegales;
