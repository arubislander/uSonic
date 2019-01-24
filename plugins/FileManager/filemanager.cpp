/*
 * Copyright 2015 Michael Sheldon <mike@mikeasoft.com>
 *
 * This file is part of Podbird.
 *
 * Podbird is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * Podbird is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <QFile>
#include <QDebug>
#include <QDir>
#include <QStandardPaths>

#include "filemanager.h"

FileManager::FileManager(QObject *parent):
    QObject(parent),
    m_songsDir(QStandardPaths::writableLocation(QStandardPaths::DataLocation) + QDir::separator() + "songs"),
    m_coverArtDir(QStandardPaths::writableLocation(QStandardPaths::DataLocation) + QDir::separator() + "coverart")
{

}

FileManager::~FileManager() {

}

QString FileManager::songsDirectory() const
{
    return m_songsDir;
}

QString FileManager::coverArtDirectory() const
{
    return m_coverArtDir;
}

void FileManager::deleteFile(QString path) {
    QFile file(path);
    if (file.exists()) {
        file.remove();
    }
}

QString FileManager::saveDownload(QString filename, QString basePath, QString origPath) {
    qDebug() << "** Entering saveDownload **";
    QDir destDir(basePath);
    if(!destDir.exists()) {
        destDir.mkpath(basePath);
    }
    QFileInfo fi(origPath);
    QFile *destFile;
    QString filePath;
    int attempts = 0;
    do {
        filePath = basePath + QDir::separator() + filename;
        if (attempts > 0) {
            filePath += "." + QString::number(attempts);
        }
        destFile = new QFile(filePath);
        attempts++;
    } while (destFile->exists());
    qDebug() << "** Renaming file to :" << filePath << " **";
    QFile::rename(origPath, filePath);
    return filePath;
}

bool FileManager::fileExists(QString path) {
    QFile file(path);
    return file.exists();
}

// QStringList FileManager::getDownloadedEpisodes() {
//     QDir destDir(m_podcastDir);
//     QStringList filters;
//     filters << "*.mp3" << "*.mp3.*" << "*.m4a" << "*.m4a.*" << "*.ogg" << "*.ogg.*" << "*.oga" << "*.oga.*" << "*.wma";
//     destDir.setNameFilters(filters);
//     return destDir.entryList();
// }
