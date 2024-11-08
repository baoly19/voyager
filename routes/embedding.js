// coding=utf-8

// Copyright [2024] [SkywardAI]
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//        http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import { Router } from "express";
import { embeddings, uploadDataset } from "../actions/embedding.js";
import { isRouteEnabled } from "../tools/enabledApiDecoder.js";

export default function embeddingRoute() {
    const router = Router();

    // TODO: Confirm with the organizer for bug fixing at here
    isRouteEnabled("embedding", "index") && router.post("/", embeddings);
    isRouteEnabled("embedding", "dataset") && router.post("/dataset", uploadDataset);

    return router;
}