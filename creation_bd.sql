-- phpMyAdmin SQL Dump
-- version 2.11.7.1
-- http://www.phpmyadmin.net
--
-- Serveur: localhost
-- Généré le : Ven 07 Octobre 2011 à 19:51
-- Version du serveur: 5.0.41
-- Version de PHP: 5.2.6

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Base de données: `TraceExplorer`
--

-- --------------------------------------------------------

--
-- Structure de la table `intervalle`
--

CREATE TABLE `intervalle` (
  `id` int(11) NOT NULL auto_increment,
  `idTimeline` int(11) NOT NULL,
  `title` varchar(255) default NULL,
  `description` varchar(2555) default NULL,
  `start` timestamp NULL default NULL,
  `end` timestamp NULL default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `media`
--

CREATE TABLE `media` (
  `id` int(11) NOT NULL auto_increment,
  `length` int(10) unsigned default NULL,
  `startDate` timestamp NULL default NULL,
  `title` varchar(300) default NULL,
  `description` varchar(5000) default NULL,
  `color` int(10) unsigned default NULL,
  `url` varchar(500) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8 ;

-- --------------------------------------------------------

--
-- Structure de la table `mediaInTimeline`
--

CREATE TABLE `mediaInTimeline` (
  `id` int(11) NOT NULL auto_increment,
  `idMedia` int(11) NOT NULL,
  `idTimeline` int(11) NOT NULL,
  `position` int(11) default NULL,
  `delay` int(11) default NULL,
  `visible` tinyint(4) NOT NULL default '1',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=12 ;

-- --------------------------------------------------------

--
-- Structure de la table `screenshot`
--

CREATE TABLE `screenshot` (
  `id` int(11) NOT NULL auto_increment,
  `filename` varchar(500) NOT NULL,
  `traceUri` varchar(500) default NULL,
  `time` bigint(15) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `filename` (`filename`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8969 ;

-- --------------------------------------------------------

--
-- Structure de la table `testflex`
--

CREATE TABLE `testflex` (
  `id` int(11) NOT NULL,
  `title` varchar(500) NOT NULL,
  `description` varchar(500) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `timeline`
--

CREATE TABLE `timeline` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `description` varchar(2555) default NULL,
  `zoomStart` int(11) default NULL,
  `zoomEnd` int(11) default NULL,
  `position` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=6 ;

-- --------------------------------------------------------

--
-- Structure de la table `trace`
--

CREATE TABLE `trace` (
  `id` int(11) NOT NULL auto_increment,
  `uri` varchar(500) default NULL,
  `title` varchar(500) default NULL,
  `description` varchar(5000) default NULL,
  `begin` bigint(15) default NULL,
  `end` bigint(15) default NULL,
  `size` int(11) default NULL,
  `subject` varchar(500) default NULL,
  `idTtl` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=60 ;

-- --------------------------------------------------------

--
-- Structure de la table `traceInTimeline`
--

CREATE TABLE `traceInTimeline` (
  `id` int(11) NOT NULL auto_increment,
  `idTimeline` int(11) NOT NULL,
  `idTrace` int(11) NOT NULL,
  `idSelector` int(11) NOT NULL,
  `position` int(11) default NULL,
  `delay` int(11) default NULL,
  `visible` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

-- --------------------------------------------------------

--
-- Structure de la table `ttl`
--

CREATE TABLE `ttl` (
  `id` int(11) NOT NULL auto_increment,
  `url` varchar(500) default NULL,
  `title` varchar(500) default NULL,
  `description` varchar(5000) default NULL,
  `begin` int(11) default NULL,
  `end` int(11) default NULL,
  `size` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=7 ;
