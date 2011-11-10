-- phpMyAdmin SQL Dump
-- version 2.11.7.1
-- http://www.phpmyadmin.net
--
-- Serveur: localhost
-- Généré le : Jeu 10 Novembre 2011 à 16:49
-- Version du serveur: 5.0.41
-- Version de PHP: 5.2.6

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Base de données: `TraceExplorer`
--

--
-- Contenu de la table `intervalle`
--


--
-- Contenu de la table `media`
--

INSERT INTO `media` VALUES(10, 1634000, '2011-01-11 14:56:46', 'S02G12', NULL, 0, 'http://cinecast.advene.org/abelin/HulstPremieres/s02g12.f4v');
INSERT INTO `media` VALUES(9, 1732000, '2011-01-11 14:54:45', 'S02G11', NULL, 0, 'http://cinecast.advene.org/abelin/HulstPremieres/s02g14.f4v');
INSERT INTO `media` VALUES(8, 2794000, '2011-01-04 14:35:35', 'S01G11', NULL, 0, 'http://cinecast.advene.org/abelin/HulstPremieres/s01g11.f4v');

--
-- Contenu de la table `mediaInTimeline`
--

INSERT INTO `mediaInTimeline` VALUES(17, 10, 8, -1, 0, 1);
INSERT INTO `mediaInTimeline` VALUES(16, 9, 6, -1, 0, 1);
INSERT INTO `mediaInTimeline` VALUES(15, 8, 6, -1, 0, 1);


--
-- Contenu de la table `timeline`
--

INSERT INTO `timeline` VALUES(8, 'S02G12', NULL, 0, 0, 0);
INSERT INTO `timeline` VALUES(7, 'sans titre', NULL, 0, 0, 0);
INSERT INTO `timeline` VALUES(6, 'S01G11', NULL, 0, 0, 0);

--
-- Contenu de la table `trace`
--

INSERT INTO `trace` VALUES(72, 'trace-20110111151106-1', NULL, NULL, 1294755067830, 1294755635900, 354, '1', 14);
INSERT INTO `trace` VALUES(71, 'trace-20110111145438-1', NULL, NULL, 1294754079790, 1294755061000, 339, '1', 14);
INSERT INTO `trace` VALUES(70, 'trace-20110111145136-1', NULL, NULL, 1294753898100, 1294754028290, 56, '1', 14);
INSERT INTO `trace` VALUES(69, 'trace-20110118145056-1', NULL, NULL, 1295358657960, 1295359968040, 413, '1', 13);
INSERT INTO `trace` VALUES(68, 'trace-20110118143413-1', NULL, NULL, 1295357654280, 1295358565900, 208, '1', 13);
INSERT INTO `trace` VALUES(67, 'trace-20110118141529-1', NULL, NULL, 1295356530360, 1295357640510, 220, '1', 13);
INSERT INTO `trace` VALUES(66, 'trace-20110118141454-1', NULL, NULL, 1295356495380, 1295356512860, 40, '1', 13);
INSERT INTO `trace` VALUES(65, 'trace-20110118141141-1', NULL, NULL, 1295356302960, 1295356313940, 34, '1', 13);
INSERT INTO `trace` VALUES(64, 'trace-20110118135907-1', NULL, NULL, 1295355548690, 1295356237510, 865, '1', 13);
INSERT INTO `trace` VALUES(63, 'trace-20110118134120-1', NULL, NULL, 1295354481730, 1295355486610, 328, '1', 13);
INSERT INTO `trace` VALUES(62, 's2g11', NULL, NULL, 1294754165660, 1294755632710, 862, '1', 12);
INSERT INTO `trace` VALUES(61, 'trace-20110104145712-1', NULL, NULL, 1294149433410, 1294150836220, 365, '1', 11);
INSERT INTO `trace` VALUES(60, 'trace-20110104143807-1', NULL, NULL, 1294148288680, 1294149426590, 408, '1', 11);

--
-- Contenu de la table `traceInTimeline`
--

INSERT INTO `traceInTimeline` VALUES(17, 8, 72, 0, -1, 0, 1);
INSERT INTO `traceInTimeline` VALUES(16, 8, 71, 0, -1, 0, 1);
INSERT INTO `traceInTimeline` VALUES(15, 8, 70, 0, -1, 0, 1);
INSERT INTO `traceInTimeline` VALUES(14, 6, 62, 0, -1, 0, 1);
INSERT INTO `traceInTimeline` VALUES(13, 6, 60, 0, -1, 0, 1);
INSERT INTO `traceInTimeline` VALUES(12, 6, 61, 0, -1, 0, 1);

--
-- Contenu de la table `ttl`
--

INSERT INTO `ttl` VALUES(14, 'http://cinecast.advene.org/abelin/HulstPremieres/s02g12.ttl', 'S02G12', NULL, 0, 0, 0);
INSERT INTO `ttl` VALUES(13, 'http://cinecast.advene.org/abelin/HulstPremieres/s03g11.ttl', 'S03G11', NULL, 0, 0, 0);
INSERT INTO `ttl` VALUES(12, 'http://cinecast.advene.org/abelin/HulstPremieres/s02g11.transformed.ttl', 'S02G11', NULL, 0, 0, 0);
INSERT INTO `ttl` VALUES(11, 'http://cinecast.advene.org/abelin/HulstPremieres/s01g11.filtered.ttl', 'S01G11', NULL, 0, 0, 0);
