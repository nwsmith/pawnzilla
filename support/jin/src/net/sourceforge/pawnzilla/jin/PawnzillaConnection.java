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

import free.chess.Chess;
import free.chess.Move;
import free.chess.WildVariant;
import free.jin.Connection;
import free.jin.Game;
import free.jin.Seek;
import free.jin.SeekConnection;
import free.jin.UserSeek;
import free.jin.event.ListenerManager;
import free.jin.event.SeekListenerManager;
import java.io.IOException;


/** Fake connection class to pawnzilla
 *
 * @author streiff
 */
 public class PawnzillaConnection implements Connection, SeekConnection {
    private boolean isLoggedIn = false;

    public ListenerManager getListenerManager() {
        return new PawnzillaListenerManager();
    }

    public void initiateConnectAndLogin(String hostname, int port) {
        isLoggedIn = true;
    }

    public boolean isConnected() {
        return isLoggedIn;
    }

    public void close() throws IOException {
    }

    public String getUsername() {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void sendCommand(String arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void exit() {
    }

    public WildVariant[] getSupportedVariants() {
        return new WildVariant[] {Chess.getInstance()};
    }

    public void quitGame(Game arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void makeMove(Game arg0, Move arg1) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void resign(Game arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void requestDraw(Game arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public boolean isAbortSupported() {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void requestAbort(Game arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public boolean isAdjournSupported() {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void requestAdjourn(Game arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public boolean isTakebackSupported() {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void requestTakeback(Game arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public boolean isMultipleTakebackSupported() {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void requestTakeback(Game arg0, int arg1) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void goBackward(Game arg0, int arg1) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void goForward(Game arg0, int arg1) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void goToBeginning(Game arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void goToEnd(Game arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void showServerHelp() {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void sendHelpQuestion(String arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public SeekListenerManager getSeekListenerManager() {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void acceptSeek(Seek arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void issueSeek(UserSeek arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }
}
