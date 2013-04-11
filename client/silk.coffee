# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
silk = roaster.dependency(
  silk: 'http://www.famfamfam.com/lab/icons/silk/famfamfam_silk_icons_v013.zip'
  )
# Load silk icons.
# require('client/silk') (path-to-icons) -> do-something()
module.exports = (next) -> silk.get(-> next('/ext/silk/icons'))
