// @ts-ignore
import * as enums from '../enums';


import { executeGet } from '../http-utils';




    export const endpointUrl = '/api/users/';
    

    export function getUsers() { return executeGet<readonly models.User[]>(endpointUrl + 'getUsers/'); }
    

    

    
