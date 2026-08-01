import { useState } from 'react';
import { ShieldCheck, Lock, Gem } from 'lucide-react';
import mockup from '../assets/mockup.png';
import appMockup from '../assets/app-mockup.png';
import cityscapeSvg from '../assets/cityscape.svg';

const Home = () => {
  const [activeTab, setActiveTab] = useState('À proximité');

  return (
    <div className="fade-in">

      {/* ===== HERO (Transit-inspired: cityscape + phone + CTA) ===== */}
      <section className="hero">
        <div className="hero-bg-gradient"></div>
        <div className="container hero-container">
          <div className="hero-content">
            <div className="hero-text">
              <div className="hero-badge">
                <span className="hero-badge-dot"></span>
                Disponible sur iOS & Android
              </div>
              <h1 className="heading-hero">
                L'appli pour vos trajets<br />
                <span className="text-orange">sans stress</span>
              </h1>
              <p className="subtitle hero-subtitle">
                Vos déplacements en Île-de-France, simplifiés
                — en bus, en train, en métro, en RER et en tram.
              </p>
              <div className="hero-cta">
                <button className="btn-download" id="download">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                    <polyline points="7 10 12 15 17 10"/>
                    <line x1="12" y1="15" x2="12" y2="3"/>
                  </svg>
                  Télécharger Flyxy
                </button>
                <a href="#features" className="btn-outline-green hero-link">
                  Découvrir
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                    <line x1="12" y1="5" x2="12" y2="19"/>
                    <polyline points="19 12 12 19 5 12"/>
                  </svg>
                </a>
              </div>
              <div className="hero-trust">
                <div className="hero-stars">★★★★★</div>
                <span className="hero-trust-text">4.8/5 — Noté par nos utilisateurs</span>
              </div>
            </div>

            <div className="hero-phone-wrapper">
              <div className="hero-phone-glow"></div>
              <img
                src={appMockup}
                alt="Flyxy App — Prochains départs en temps réel"
                className="hero-phone"
              />
            </div>
          </div>
        </div>

        {/* Cityscape silhouette */}
        <div className="hero-cityscape">
          <img src={cityscapeSvg} alt="" className="hero-cityscape-img" aria-hidden="true" />
        </div>
      </section>

      {/* ===== SECTION 2: Feature card GREEN (like Transit's tabbed green card) ===== */}
      <div className="container">
        <div className="feature-card feature-card-green">
          <div className="tab-pills">
            {['À proximité', 'Temps réel', 'Recherche vocale', 'Carte'].map((tab) => (
              <button 
                key={tab}
                className={`tab-pill ${activeTab === tab ? 'tab-pill-active' : 'tab-pill-inactive'}`}
                onClick={() => setActiveTab(tab)}
              >
                {tab}
              </button>
            ))}
          </div>
          <div className="feature-card-inner">
            <div className="feature-card-text">
              <h2 className="heading-section text-white" style={{ marginBottom: '20px' }}>
                {activeTab === 'À proximité' && <>Toute l'info<br />qu'il vous faut</>}
                {activeTab === 'Temps réel' && <>Horaires en<br />temps réel</>}
                {activeTab === 'Recherche vocale' && <>Dictez votre<br />destination</>}
                {activeTab === 'Carte' && <>Où sont<br />les véhicules ?</>}
              </h2>
              <p className="subtitle text-white" style={{ opacity: 0.9 }}>
                {activeTab === 'À proximité' && "Ouvrez l'appli pour tout de suite voir toutes les options à proximité : bus, métro, RER, tramway. Rien à chercher, rien à taper."}
                {activeTab === 'Temps réel' && "Les prochains départs s'affichent en temps réel, automatiquement. Fiez-vous aux horaires en vert pour ne plus rater votre bus."}
                {activeTab === 'Recherche vocale' && "Les mains prises dans le métro ? Utilisez la recherche vocale pour trouver votre itinéraire sans taper un seul mot."}
                {activeTab === 'Carte' && "Visualisez la position exacte des véhicules sur la carte interactive. Anticipez votre trajet en un coup d'œil."}
              </p>
            </div>
            <div className="feature-card-visual">
              <img src={appMockup} alt={`Flyxy ${activeTab}`} className="feature-card-phone" />
            </div>
          </div>
        </div>
      </div>

      {/* ===== SECTION 3: Feature card YELLOW (like Transit's community card) ===== */}
      <div className="container">
        <div className="feature-card feature-card-yellow">
          <div className="feature-card-inner reverse">
            <div className="feature-card-text">
              <h2 className="heading-section" style={{ marginBottom: '20px' }}>
                Du transport<br />réellement collectif
              </h2>
              <p className="subtitle" style={{ opacity: 0.85 }}>
                Ligne en retard ? Prévenez les autres voyageurs instantanément.
                Flyxy est le premier réseau social dédié aux transports franciliens.
                Partagez l'info, aidez la communauté, et recevez les alertes
                des autres passagers en temps réel.
              </p>
            </div>
            <div className="feature-card-visual">
              <img src={mockup} alt="Communauté Flyxy" className="feature-card-phone" />
            </div>
          </div>
        </div>
      </div>

      {/* ===== SECTION 4: Feature card ORANGE (like Transit's survey/feedback card) ===== */}
      <div className="container">
        <div className="feature-card feature-card-orange">
          <div className="feature-card-inner">
            <div className="feature-card-text">
              <h2 className="heading-section text-white" style={{ marginBottom: '20px' }}>
                Dictez votre<br />destination
              </h2>
              <p className="subtitle text-white" style={{ opacity: 0.9 }}>
                Les mains prises dans le métro ? Utilisez la recherche vocale
                pour trouver votre itinéraire sans taper un seul mot.
                Flyxy comprend où vous voulez aller et vous guide
                étape par étape, jusqu'à votre arrêt.
              </p>
            </div>
            <div className="feature-card-visual">
              <img src={mockup} alt="Recherche vocale Flyxy" className="feature-card-phone" />
            </div>
          </div>
        </div>
      </div>

      {/* ===== SECTION 5: Coverage (like Transit's "Des centaines de villes") ===== */}
      <section className="section">
        <div className="container">
          <div className="split-row">
            <div className="split-text">
              <h2 className="heading-section" style={{ marginBottom: '20px' }}>
                Toute l'Île-de-France,<br />
                <span className="text-orange">dans votre poche.</span>
              </h2>
              <p className="subtitle" style={{ marginBottom: '24px' }}>
                RATP, SNCF Transilien, Île-de-France Mobilités — toutes les données
                de transport de la région, unifiées dans une seule application
                claire et rapide.
              </p>
              <p className="subtitle">
                Bus, métro, RER, tramway, Transilien :
                tous les modes de transport sont couverts.
              </p>
            </div>
            <div className="split-visual">
              <img src={mockup} alt="Couverture Flyxy" className="split-phone" />
            </div>
          </div>
        </div>
      </section>

      {/* ===== SECTION 6: Reviews (like Transit's App Store reviews carousel) ===== */}
      <section className="section section-grey">
        <div className="container">
          <h2 className="heading-section" style={{ textAlign: 'center', marginBottom: '48px' }}>
            Ce qu'en disent<br />nos utilisateurs
          </h2>
          <div className="reviews-row">
            <div className="review-card">
              <div className="review-stars">★★★★★</div>
              <p className="review-text">
                « Appli complète et bien pensée. Les horaires en temps réel sont précis,
                la recherche vocale est un vrai plus quand on est pressé. Je l'utilise
                tous les jours pour mes trajets. »
              </p>
              <div className="review-source">App Store</div>
            </div>
            <div className="review-card">
              <div className="review-stars">★★★★★</div>
              <p className="review-text">
                « L'appli est simple et très pratique. Rien qu'en l'ouvrant,
                le système de géolocalisation simplifie grandement les choses.
                Plus besoin de chercher son arrêt manuellement ! »
              </p>
              <div className="review-source">Google Play</div>
            </div>
            <div className="review-card">
              <div className="review-stars">★★★★★</div>
              <p className="review-text">
                « Tout ce que l'informatique peut faire de mieux pour nous aider
                au quotidien. Savoir en temps réel quelles sont les lignes de transport
                autour de soi, c'est magique. »
              </p>
              <div className="review-source">App Store</div>
            </div>
            <div className="review-card">
              <div className="review-stars">★★★★★</div>
              <p className="review-text">
                « La fonctionnalité communautaire est géniale. On peut prévenir
                les autres usagers en cas de retard. C'est vraiment le Waze
                du transport en commun ! »
              </p>
              <div className="review-source">Google Play</div>
            </div>
          </div>
        </div>
      </section>

      {/* ===== SECTION 7: Privacy (like Transit's funding/privacy section) ===== */}
      <section className="section">
        <div className="container">
          <h2 className="heading-section" style={{ textAlign: 'center', marginBottom: '64px' }}>
            Gratuite et respectueuse<br />de vos données
          </h2>
          <div className="split-row">
            <div className="split-visual" style={{ justifyContent: 'center' }}>
              <img src={mockup} alt="Confidentialité Flyxy" className="split-phone" />
            </div>
            <div className="split-text">
              <div className="privacy-point">
                <div className="privacy-icon privacy-icon-blue"><Lock size={24} color="#2563eb" /></div>
                <div>
                  <div className="privacy-title">Vos données restent les vôtres</div>
                  <p className="privacy-desc">
                    Pas de pisteur en arrière-plan, pas de publicités ciblées.
                    Votre position sert uniquement à trouver les arrêts autour de vous.
                  </p>
                </div>
              </div>
              <div className="privacy-point">
                <div className="privacy-icon privacy-icon-purple"><ShieldCheck size={24} color="#7c3aed" /></div>
                <div>
                  <div className="privacy-title">Sécurité maximale</div>
                  <p className="privacy-desc">
                    Mots de passe chiffrés, communications HTTPS,
                    sessions sécurisées par JWT. Vos informations sont protégées.
                  </p>
                </div>
              </div>
              <div className="privacy-point">
                <div className="privacy-icon privacy-icon-orange"><Gem size={24} color="#d97706" /></div>
                <div>
                  <div className="privacy-title">100% gratuite, sans pub</div>
                  <p className="privacy-desc">
                    Flyxy est gratuite pour tout le monde. Pas de version premium,
                    pas de fonctionnalités cachées derrière un abonnement.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ===== SECTION 8: Vision (like Transit's "Notre vision") ===== */}
      <section className="section section-grey">
        <div className="container">
          <div className="split-row">
            <div className="split-text">
              <h2 className="heading-section" style={{ marginBottom: '20px' }}>
                Notre vision
              </h2>
              <p className="subtitle" style={{ marginBottom: '24px' }}>
                Notre équipe croit que les transports en commun ont le pouvoir
                de transformer nos villes pour le mieux. En simplifiant l'accès
                à l'information voyageur, on rend le transport collectif
                aussi simple qu'un trajet en voiture.
              </p>
              <p className="subtitle" style={{ marginBottom: '32px' }}>
                Flyxy est née d'une frustration : pourquoi est-ce si compliqué
                de savoir quand passe le prochain bus ? Notre mission est de rendre
                cette information accessible à tous, instantanément.
              </p>
              <button className="btn-outline-green">
                En savoir plus
              </button>
            </div>
            <div className="split-visual">
              <img src={mockup} alt="Vision Flyxy" className="split-phone" />
            </div>
          </div>
        </div>
      </section>

      {/* ===== SECTION 9: Final CTA (like Transit's download + quote section) ===== */}
      <section className="cta-final">
        <div className="container">
          <p className="cta-quote">
            « La meilleure appli pour les<br />
            transports <span className="text-orange">en Île-de-France</span> »
          </p>
          <p className="cta-attribution">— Nos utilisateurs</p>
          <button className="btn-download" style={{ fontSize: '1.2rem', padding: '20px 48px' }}>
            Télécharger Flyxy
          </button>
        </div>
      </section>

    </div>
  );
};

export default Home;
