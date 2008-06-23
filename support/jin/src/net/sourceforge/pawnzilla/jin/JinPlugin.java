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

import free.jin.Server;
import free.jin.Connection;
import free.jin.ConnectionDetails;
import free.jin.User;
import free.jin.UsernamePolicy;

/** Communication class with Jin Chess client
 *
 * @author streiff
 */
public class JinPlugin implements Server {

    /** Pawnzilla doesn't need a server, but we must mock a username policy */
    private static final UsernamePolicy usernamePolicy = new UsernamePolicy() {
        public boolean isSame(String username1, String username2) {
            return username1.equalsIgnoreCase(username2);
        }

        public String invalidityReason(String username) {
            return null;
        }

        public String getGuestUsername() {
            return "guest";
        }
    };
    
    private User guestUser;

    

    public Connection createConnection(ConnectionDetails connDetails) {
        return new PawnzillaConnection();
    }

    public void setGuestUser(User user) {
        guestUser = user != null 
                ? user : new User(this, usernamePolicy.getGuestUsername());
    }

    public User getGuest() {
        return guestUser;
    }

    public String getDefaultHost() {
        return getHosts()[0];
    }

    public String[] getHosts() {
        return new String[] {"localhost.localdomain"};
    }

    public void setHost(String arg0) {
        // don't have any real hosts... so we don't need to implement anything
    }

    public int[] getPorts() {
        return new int[] {12345};
    }

    public void setPort(int arg0) {
        // don't have any real posts... so we don't need to implement anything
    }

    public String getId() {
        return "pawnzilla";
    }

    public String getShortName() {
        return "Pawnzilla";
    }

    public String getLongName() {
        return "Pawnzilla Chess Engine";
    }

    public String getWebsite() {
        return "https://sourceforge.net/projects/pawnzilla";
    }

    public String getRegistrationPage() {
        return "Local chess engine - no registration required.";
    }

    public String getPasswordRetrievalPage() {
        return "Local chess engine - no password required";
    }

    
    public UsernamePolicy getUsernamePolicy() {
        return usernamePolicy;
    }
    
    @Override
    public String toString(){
        return getLongName() + " (" + getWebsite() + ")";
    }

}
