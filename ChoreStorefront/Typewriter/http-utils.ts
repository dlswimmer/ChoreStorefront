
// export function sendEmail(updateModel: OrderUpdateModelWithUniqueKeys): ThunkResult {

//     return async dispatch => {

//         const model = cleanUpdateModel(updateModel);

//         dispatch(actionCreators.sendEmail());

//         const url = ordersEndpoint + 'update/';

//         try {
//             const result = await executePost<models.DefaultCommandResult>(url, url, model);
//             dispatch(ActionCreators.updateContactInfoSuccess(model));
//             return result;

//         } catch (error) {
//             dispatch(ActionCreators.updateContactInfoError());
//             dispatch(ErrorActions.showError({ message: error.message, error }));
//             return undefined;
//         }
//     };
// }

let hahContext: string;
let requestHeaders: Record<string, string> = {
    'Content-Type': 'application/json',
}
export function setHahContext(context: string) {
    hahContext = context;
    requestHeaders = {
        ...requestHeaders,
        'Hah-Context': context
    };
}


export let unauthorizedRequestHandler = (response: Response) => { };
export function setUnauthorizedRequestHandler(handler: (response: Response) => void) {
    unauthorizedRequestHandler = handler || (() => { });
}


export function getRequestHeaders() {
    return requestHeaders;
}

export function executePost<TResult, TPost = any>(url: string, postData?: TPost): CancellablePromise<TResult> {

    return executeFetch<TResult>(url, {
        method: 'POST',
        credentials: 'same-origin',
        headers: requestHeaders,
        body: JSON.stringify(postData),
    });

}

export function executeGet<TResult>(url: string): CancellablePromise<TResult> {

    return executeFetch<TResult>(url, {
        method: 'GET',
        credentials: 'same-origin',
        headers: requestHeaders,
    });

}

export function executeFetch<TResult>(url: string, init: RequestInit): CancellablePromise<TResult> {

    const controller = new AbortController();

    const result = fetch(url, { ...init, signal: controller.signal }).then(response => {

        if (controller.signal.aborted) {
            return { cancelled: true } as any;
        }
        if (response.ok) {
            return response.json() as Promise<TResult>;
        }

        if (response.status == 401) {
            unauthorizedRequestHandler(response);
            throw new Error('User not logged in');
        }

        return response.json().then(error => {
            throw formatAndThrowWebApiError(error);
        });

    }, error => {
        if (!controller.signal.aborted) {
            throw error;
        }
        //debuglog('executeFetch aborted', {url});
        return { cancelled: true };
    }) as CancellablePromise<TResult>;

    result.abort = () => {
        controller.abort();
    }
    return result;

}

export interface CancellablePromise<T> extends Promise<T & { cancelled?: true }> {
    abort(): void;
}



/**
 * Takes a given error object from WebAPI and formats it nicer.
 * @param error
 */
export function formatAndThrowWebApiError(error: any): Error {
    let message = error.ExceptionMessage || error.Message || 'Unknown error';

    // FUTURE: really this extra data should probably only render for admins? i dunno. im conflicted. i guess lets start with it all.

    if (error.ExceptionType) {
        message += '\r\nException Type: ' + error.ExceptionType;
    }

    if (error.StackTrace) {
        message += '\r\nStack: ' + error.StackTrace;
    }

    const err = new Error(message);
    error.data = error;
    return err;
}
