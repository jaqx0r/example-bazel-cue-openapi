import React from "react";
import { createRoot } from "react-dom/client";

function Frontend() {
    return (
        <>
            <h1>Hello</h1>
            </>
    );
}

const domNode = document.getElementById("root")!;
const root = createRoot(domNode);
root.render(<React.StrictMode>
    <Frontend />
    </React.StrictMode>
    );
