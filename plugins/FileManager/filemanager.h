/*
 * Copyright 2014 Michael Sheldon <mike@mikeasoft.com>
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

#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QObject>

class FileManager : public QObject
{
    Q_OBJECT

    // READONLY Property to return the songs directory path
    Q_PROPERTY( QString songsDirectory
                READ songsDirectory
                CONSTANT)

    // READONLY Property to return the cover art directory path
    Q_PROPERTY( QString coverArtDirectory
                READ coverArtDirectory
                CONSTANT)
public:
    explicit FileManager(QObject *parent = 0);
    ~FileManager();

    QString songsDirectory() const;
    QString coverArtDirectory() const;

public:
    Q_INVOKABLE void deleteFile(QString path);
    Q_INVOKABLE QString saveDownload(QString filename, QString basePath, QString downloadPath);
    //Q_INVOKABLE QStringList getDownloadedEpisodes();
    Q_INVOKABLE bool fileExists(QString path);

private:
    QString m_songsDir;
    QString m_coverArtDir;

};

#endif // FILEMANAGER_H
