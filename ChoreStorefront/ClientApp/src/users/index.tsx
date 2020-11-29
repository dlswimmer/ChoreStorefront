import * as React from 'react';
import { webapi } from '~/typewriter/controllers';


export const UsersList = async () => {
    const users = await webapi.users.getUsers();

    return <div>
        <h2>Users</h2>
    </div>;
}