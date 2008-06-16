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

import free.jin.AbstractServer;
import free.jin.Connection;
import free.jin.ConnectionDetails;
import free.jin.UsernamePolicy;

/** Communication class with Jin Chess client
 *
 * @author streiff
 */
public class JinPlugin extends AbstractServer {

    @Override
    protected UsernamePolicy createUsernamePolicy() {
        return new UsernamePolicy() {

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
    }

    public Connection createConnection(ConnectionDetails arg0) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

}
