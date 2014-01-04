# Copyright 2013 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import hashlib

DATA = 'I am the fluffiest of bunnies'
MIMETYPE = 'text/plain'
CHARSET = 'utf-8'

def Execute(api):
  csum = hashlib.sha256(DATA)
  csum.update(str(len(DATA)))
  csum.update(MIMETYPE)
  csum.update(CHARSET)
  ex_files = [{
    'cas_id': {
      'csum': csum.hexdigest(),
      'content_type': MIMETYPE,
      'charset': CHARSET
    },
    'data': DATA.encode('base64'),
  }]

  api.login()
  me = api.GET('accounts/me').json
  api.PUT('cas_entries', json=ex_files, xsrf=me['data']['xsrf'],
          compress=True)
