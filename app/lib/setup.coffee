# Leave out what we don't need, until we need it
# require('json2ify')
# require('es5-shimify')
# require('jqueryify')

Spine = require('spine') 
# require('spine/lib/local')
# require('spine/lib/ajax')
# require('spine/lib/manager')
# require('spine/lib/route')
# require('spine/lib/tmpl')

Spine.Module::log = (info...) -> console.log info...