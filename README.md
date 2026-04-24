# TaskFlow – Gestion Intelligente de Tâches

TaskFlow est une application mobile Flutter moderne conçue pour organiser le travail individuel et collaboratif. Développée dans le cadre d'un mini-projet, elle met l'accent sur une architecture propre (MVVM), un design unique et premium, et une expérience utilisateur fluide.

## 🌟 Fonctionnalités

### Core
- **Authentification complète** : Inscription et connexion avec persistance de session historique.
- **Gestion des tâches (CRUD)** : Création, lecture, modification et suppression de tâches.
- **Gestion des projets** : Organisation des tâches par projets avec calcul de progression.
- **Collaboration** : Assignation de tâches entre utilisateurs inscrits et membres de projets.
- **Tableau de bord intelligent** : Statistiques en temps réel, greeting dynamique et vue sur les tâches récentes.

### Bonus & Plus
- **Tests Unitaires** : Validation de la logique métier (modèles).
- **Synchronisation API (Mock)** : Simulation de communication avec un backend via `ApiSyncService`.
- **Mode Sombre / Clair** : Thème complet "Soft Aurora" s'adaptant aux préférences.
- **Internationalisation** : Support du Français et de l'Anglais avec sélecteur de langue.
- **Notifications Locales** : Reminders pour les deadlines (5 minutes avant l'échéance).
- **Design Premium** : Animations staggered, palette de couleurs pastel, Custom Sweet Alerts pour les dialogues.
- **Persistance Locale** : Utilisation de Hive pour une rapidité optimale hors-ligne.

---

## 🏗️ Architecture et Structure du Projet

L'application respecte rigoureusement le pattern **MVVM (Model-View-ViewModel)**. Ce choix permet de séparer totalement la logique métier de l'interface graphique, facilitant la maintenance et les tests.

Voici le détail complet de la structure du dossier `lib/` et le rôle de chaque fichier :

### 📂 `lib/` (Racine)
- 📄 `main.dart` : **Point d'entrée** de l'application. Initialise les services asynchrones (Hive, Notifications) avant de lancer Flutter.
- 📄 `app.dart` : **Configuration globale**. Configure le `MaterialApp`, gère les changements de thèmes, les langues (Localizations) et injecte le routeur.

### 📂 `lib/core/` (Cœur de l'application)
Contient tous les éléments transversaux, utiles à travers toute l'application.
- 📂 `constants/`
  - 📄 `app_colors.dart` : Définit la palette de couleurs "Soft Aurora" (Primary, Secondary, Success, etc.).
  - 📄 `app_text_styles.dart` : Centralise toutes les typographies (Titre 1, Titre 2, Corps de texte) pour garantir une cohérence visuelle.
- 📂 `routes/`
  - 📄 `app_router.dart` : Configure `GoRouter`. Gère toute la navigation, les redirections de sécurité (impossible d'aller sur l'accueil si non connecté) et les routes avec paramètres.
- 📂 `services/`
  - 📄 `api_sync_service.dart` : Service de "mock" simulant un appel API asynchrone pour la synchronisation Cloud.
  - 📄 `hive_service.dart` : Gère l'ouverture, la fermeture et l'enregistrement des boîtes (tables) de la base de données locale Hive.
  - 📄 `notification_service.dart` : Gère l'envoi et la programmation des notifications locales via le système natif (Android/iOS).
- 📂 `theme/`
  - 📄 `app_theme.dart` : Construit les thèmes `lightTheme` et `darkTheme` de Material 3 avec les couleurs personnalisées.
  - 📄 `theme_provider.dart` : Permet le basculement dynamique (Light/Dark mode) en direct.
- 📂 `utils/`
  - 📄 `data_generator.dart` : Script utilisé pour générer des données de démonstration lors du premier lancement.

### 📂 `lib/models/` (Modèles de données)
Définit la structure des entités de la base de données.
- 📄 `enums.dart` : Énumérations pour les statuts (Todo, InProgress, Done) et priorités.
- 📄 `user_model.dart` : Modèle de l'Utilisateur (avec adaptateur Hive).
- 📄 `project_model.dart` : Modèle du Projet (membres, progression, deadlines).
- 📄 `task_model.dart` : Modèle de la Tâche (avec fonction `copyWith` testée unitairement).

### 📂 `lib/repositories/` (Accès aux données)
Ces classes sont responsables des requêtes vers la base de données (Hive). Elles cachent la complexité du stockage au reste de l'application.
- 📄 `auth_repository.dart` : Connexion, inscription, récupération de l'utilisateur actif.
- 📄 `project_repository.dart` : Opérations CRUD (Create, Read, Update, Delete) sur les projets.
- 📄 `task_repository.dart` : Opérations CRUD sur les tâches.

### 📂 `lib/viewmodels/` (Logique Métier - Gestion d'état)
C'est le pont entre l'UI et les Repositories. Gère les états de chargement et réagit aux actions utilisateurs via le package `Provider`.
- 📄 `auth_viewmodel.dart` : Gère l'état de la session (Connecté/Déconnecté) et les erreurs de login.
- 📄 `project_viewmodel.dart` : Gère le filtrage et la liste des projets de l'utilisateur.
- 📄 `settings_viewmodel.dart` : Gère les préférences (Langue FR/EN, Activation des notifications).
- 📄 `task_viewmodel.dart` : Gère la liste des tâches, les statistiques, le calcul des pourcentages et planifie les notifications (-5 min) via le service dédié.

### 📂 `lib/views/` (Interface Graphique)
Contient l'ensemble des écrans visibles par l'utilisateur, organisés par "features" (fonctionnalités). Chaque dossier contient un fichier principal `_screen.dart` et un dossier `widgets/` pour ses composants isolés.
- 📂 `auth/` : Écrans de Login et Register.
- 📂 `home/` : Le Dashboard (`home_screen.dart`) affichant les statistiques (`stats_card.dart`).
- 📂 `profile/` : L'écran des paramètres (`profile_screen.dart`) pour changer de langue/thème et se déconnecter.
- 📂 `projects/` : 
  - 📄 `projects_screen.dart` : Liste des projets.
  - 📄 `add_edit_project_screen.dart` : Formulaire de création/édition.
  - 📄 `project_details_screen.dart` : Vue détaillée de l'équipe et de la progression.
- 📂 `tasks/` :
  - 📄 `tasks_screen.dart` : Liste et système de filtrage des tâches.
  - 📄 `add_edit_task_screen.dart` : Formulaire complexe avec `DatePicker` et `TimePicker`.
  - 📄 `task_details_screen.dart` : Résumé d'une tâche et bouton d'action principal.
- 📂 `shared/` : Composants réutilisables sur plusieurs écrans.
  - 📄 `main_layout.dart` : Le squelette contenant la barre de navigation du bas (BottomNavigationBar).
  - 📄 `custom_app_bar.dart` : L'en-tête standardisée de l'application.
  - 📄 `custom_sweet_dialog.dart` : Les magnifiques pop-ups d'alertes animées (Succès, Erreur, Avertissement).
  - 📄 `empty_state.dart` : L'illustration qui s'affiche quand une liste est vide.

### 📂 `test/` (Tests automatisés)
- 📂 `models/`
  - 📄 `task_model_test.dart` : Test unitaire pour valider le comportement du modèle de Tâche.

---

## 🛠️ Stack Technique

- **State Management** : Provider
- **Base de données** : Hive (NoSQL local)
- **Localisation** : intl + Flutter Gen
- **Thème** : Material 3 personnalisé
- **Navigation** : GoRouter 14+

## 🚀 Installation & Lancement

1. **Cloner le dépôt**
2. **Installer les dépendances** :
   ```bash
   flutter pub get
   ```
3. **Lancer l'application** :
   ```bash
   flutter run
   ```
