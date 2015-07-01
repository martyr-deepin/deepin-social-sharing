#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014~2016 Deepin, Inc.
#               2014~2016 penghui
#
# Author:     penghui <penghuilater@gmail.com>
# Maintainer: penghui <penghuilater@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

FACE_DICT = {
    '1f601':'grinning',# face with smiling eyes',
    '1f602':'smiling with tear',# tears of joy',
    '1f603':'smiling first',
    '1f604':'smiling second',
    '1f609':'winking',
    '1f60a':'smiling third',
    '1f60c':'relieved',
    '1f612':'unamused',
    '1f613':'face with cold sweat',
    '1f614':'pensive',
    '1f616':'confounded',
    '1f618':'throwing a kiss',
    '1f620':'angry',
    '1f621':'pouting',
    '1f623':'persevering',
    '1f625':'disappointed but relieved',
    '1f628':'fearful',
    '1f630':'cold sweat',
    '1f631':'screaming with fear',
    '1f633':'flushed',
    '1f637':'medical mask',
    '1f60d':'smiling with heart',
    '1f60f':'smirking',
    '1f61a':'kissing',
    '1f61c':'stuck-out first',
    '1f61d':'stuck-out second',
    '1f61e':'disappointed',
    '1f62a':'sleepy',
    '1f62d':'loudly crying',
    '1f645':'no good',
    '1f646':'ok',
    '1f647':'bowing deeply',
    '1f3e0':'house',
    '1f4a3':'bomb',
    '1f4aa':'flexed biceps',
    '1f4f1':'phone',
    '1f31f':'star',
    '1f33b':'sunflower',
    '1f37a':'beer',
    '1f44a':'fisted',
    '1f44d':'thumbs',
    '1f44e':'down',
    '1f44f':'clapping',
    '1f47b':'ghost',
    '1f48e':'diamond',
    '1f50d':'magnifiy',
    '1f64d':'frowning',
    '1f64c': 'celebrating',
    '1f64f':'blessing',
    '1f319':'moon',
    '1f339':'rose',
    '1f341':'leaf',
    '1f343':'leaf fluttering',
    '1f380':'ribbon',
    '1f381':'present',
    '1f382':'birthday cake',
    '1f385':'christmas',
    '1f431':'cat',
    '1f436':'dog',
    '1f444':'mouth',
    '1f446':'up',
    '1f447':'down',
    '1f448':'left',
    '1f449':'right',
    '1f457':'dress',
    '1f466':'boy',
    '1f467':'girl',
    '1f468':'man',
    '1f469':'woman',
    '1f494':'broken heart',
    '1f559':'clock',
    '1f645':'no good',
    '1f646':'ok',
    '1f647':'bowing',
    '1f697':'car',
    '26bd':'ball',
    '270a':'raised',
    '270c':'victory',
    '2600':'sun',
    '2601':'cloud',
    '2614':'umbrella with rain',
    '2615':'hot beverage',
    '2764':'heart',
}

def getValue(str):
    return FACE_DICT.get(str, 'default-value')


def getKey(str):
    for key in FACE_DICT.viewkeys():
        if FACE_DICT[key] == str:
            return key

    return 'default-value'

