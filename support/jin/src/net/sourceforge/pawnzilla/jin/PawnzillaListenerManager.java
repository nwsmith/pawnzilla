/*
 *   $Id$
 *
 *   Copyright 2005-2008 Nathan Smith, Sheldon Fuchs, Ron Thomas
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

package net.sourceforge.pawnzilla.jin;

import free.jin.event.ChatListener;
import free.jin.event.ConnectionListener;
import free.jin.event.GameListener;
import free.jin.event.ListenerManager;
import free.jin.event.PlainTextListener;
import java.util.LinkedList;
import java.util.List;

/** Fake listener manager for pawnzilla
 *
 * @author streiff
 */
public class PawnzillaListenerManager implements ListenerManager {
    private List<ConnectionListener> listeners = 
            new LinkedList<ConnectionListener>();

    public void addConnectionListener(ConnectionListener listener) {
        listeners.add(listener);
    }

    public void removeConnectionListener(ConnectionListener listener) {
        listeners.remove(listener);
    }

    public void addPlainTextListener(PlainTextListener arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void removePlainTextListener(PlainTextListener arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void addChatListener(ChatListener arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void removeChatListener(ChatListener arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void addGameListener(GameListener arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void removeGameListener(GameListener arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

}
