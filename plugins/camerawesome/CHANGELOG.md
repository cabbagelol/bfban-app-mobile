# 2.4.0

-
upgrade
cameraX
to
1.3.4 (
thanks
@fabricio-sisplan)
-
upgrade
dependencies
-
preview
fit
is
now
contain
by
default
-
Allow
simultaneous
video
recording
and
image
analysis (
thanks
@haf
Henrik
Feldt)
-
Fix:
conflict
name
between
Preview
from
cameraawesome
and
a
new
class
preview
from
flutter (
thanks
@juarezfranco
Juarez
Franco)

# 2.0.1

-
🐛
Fix
preview
orientation
on
tablets
for
iOS
and
Android
-
🐛
Fix
preview
alignment
-
🐛
Fix
get
preview
size
on
iOS

# 2.0.0 - Multi camera is here !

Hello
everyone
👋 !

We
are
proud
to
announce
the
two
most
requested
features
on
the
official
camera
plugin:

-
Multi-camera
📹
-
Video
settings
🎥
-
Preview
rework
📸

This
release
introduces
breaking
changes
in
order
to
support
above
features.
See
the
[migration guide](https://docs.page/Apparence-io/camera_awesome/migration_guides/from_1_to_2)
for
details.

Here
is
the
complete
changelog:

-
✨
Added
multi-camera
feature,
allowing
users
to
display
multiple
camera
previews
simultaneously.
Note
that
this
feature
is
currently
in
beta,
and
we
do
not
recommend
using
it
in
production.
-
✨
Users
can
now
pass
options (
such
as
bitrate,
fps,
and
quality)
when
recording
a
video.
-
✨
You
can
now
mirror
video
recording.
-
✨🍏
Implemented
brightness
and
exposure
level
settings
on
iOS /
iPadOS.
-
✨🤖
Added
zoom
indicator
UI.
-
✨🤖
Video
recording
is
now
mirrored
if
`mirrorFrontCamera`
is
set
to
true.
-
♻️🍏
Completely
reworked
the
code
for
increased
clarity
and
performance.
-
🐛
Fixed
patrol
tests.
-
🐛
Fixed
the
use
of
capture
button
parameter
in
awesome
bottom
actions (
thanks
to
@juliuszmandrosz).
-
📝
Added
Chinese
README.md (
thanks
to
@chyiiiiiiiiiiii).
-
↗️
Android
CameraX
version
is
now
1.3.0
-
takePhoto
ans
stopVideoRecording
now
have
callbacks
for
success
and
error.
-
by
default
the
awesome
builder
has
a
filter
list
but
you
can
pass
an
empty
list
to
remove
it

# 1.4.0

-
✨
Add
utilities
to
convert
AnalysisImage
into
JPEG
in
order
to
display
them
using
`toJpeg()`.
-
✨
Add
`preview()`
and
`analysisOnly()`
constructors
to
`CameraAwesomeBuilder`.
-
✨
Volume
button
trigger
to
take
picture
or
record/stop
video.
-
✨🍏
Add
brightness
exposure
level
on
iOS /
iPadOS.
-
💥
AnalysisConfig
has
changed
slightly
its
parameters
to
have
platform-specific
setup.
-
💥
Storage
permission
is
now
optional
on
Android
since
the
introduction
of
`preview()`
and
`analysisOnly()`
modes.
-
🐛🍏
iOS /
iPadOS
max
zoom
limit.
-
🐛🤖
Better
handle
use
cases
conflicts (
video +
image
analysis
on
lower-end
devices)
for
Android.

# 1.3.1

-
🐛
Fix
video
recording
overlay
image.
-
📝
Update
README.md (
change
feature
showcase
image &
fix
broken
links).

# 1.3.0

-
✨
Customize
the
built-in
UI
by
setting
an
`AwesomeTheme`.
-
✨
Top,
middle
and
bottom
parts
of
`CameraAwesomeBuilder.awesome()`
can
now
be
replaced
by
your
own.
-
✨
Ability
to
set
camera
preview
alignment
and
padding.
-
✨
Ability
to
set
aspect
ratio,
zoom,
flash
mode
and
SensorType
when
switching
between
front
and
back
camera.
-
✨
Enable/disable
front
camera
mirroring.
-
⬆️
Upgrade
`image`
dependency.
-
🐛
Fix
aspect
ratio
changes
animation.
-
🐛
Smoother
flash
mode
changes (
Android).
-
🐛
Fix
microphone
permission (
iOS).
-
🐛
Fix
recorded
video
orientation (
iOS).
-
🐛
Fix
initial
aspect
ratio
not
set (
iOS).
-
📝
Updated
documentation
and
more
examples.
-
🎨
Format
code.

# 1.2.1

-
Expose
Gradle
variables
to
avoid
conflict
with
other
plugins.
-
iOS
aspect
ratio
fix.

# 1.2.0

-
Add
filters
for
photo
mode.
-
Rework
UI
for
awesome
layout.
-
Add
start
and
stop
method
for
image
analysis.
-
*
*BREAKING
**
Location
and
audio
recording
permissions
are
now
optional.
Add
them
to
your
AndroidManifest
manually
if
you
need
them.
-
Fix
preview
aspectRatio
on
iOS.

# 1.1.0

-
Use [
*
*pigeon
**](https://pub.dev/packages/pigeon)
for
iOS
instead
of
classic
method
channel.
-
Greatly
improve
performances
on
analysis
mode
when
FPS
limit
disabled.
-
Fix
barcode
scrolling
to
bottom.
-
Fix
iOS
stream
guards.

# 1.0.0+4

-
Code
formatting
and
linter

# 1.0.0

-
Bugfixes (
imageAnalysis,
initialAspectRatio...)
-
Sensor
type
switching (
iOS)
-
Improve
AI
documentation
-
Add
`previewSize`
and
`previewRect`
to
`CameraAwesomeBuilder`
builders

# 1.0.0-rc1

-
Full
rework
of
the
API
-
Better
feature
parity
between
iOS
and
Android
-
Use
the
built-in
camera
UI
or
make
your
own
-
Add
docs.page
documentation

# 0.4.0

-
Migrate
to
CameraX
instead
of
Camera2
on
Android.
-
Add
GPS
location
in
Exif
photo
on
Android.
-
Add
Video
recording
for
Android.

# 0.3.6

-
Add
GPS
location
in
Exif
photo
on
iOS.
-
Fix
some
issues

# 0.3.4

-
Add
pinch
to
zoom.

# 0.3.3

-
update
android
build
tools
to
30
-
fix
first
permission
request
crash

# 0.3.2

-
Update
to
Flutter
3.
-
Update
Android
example
project.
-
Upgrade
dependencies.
-
Clean
some
code.

# 0.3.1

-
handle
app
lifecycle (
stop
camera
on
background)

# 0.3.0

-
Migrate
null
safety.
-
Fixed
aspect
ratio
of
camera
preview
when
using
smaller
image
sizes.
-
Fixed
image
capture
on
older
android
devices
which
use
continuous (
passive)
focus.
-
Fix
image
capture
on
iOS

# 0.2.1+1

-
build
won't
show
red
screen
in
debug
if
camerAwesome
is
running
on
slow
phones
- [Android]
  bind
  activity

# 0.2.1

- [iOS]
  image
  stream
  available
  to
  use
  MLkit
  or
  other
  image
  live
  processing
- [iOS]
  code
  refactoring

# 0.2.0

- [iOS]
  video
  recording
  support
- [iOS]
  thread
  and
  perf
  enhancements

# 0.1.2+1

- [Android]
  onDetachedFromActivity :
  fix
  stopping
  the
  camera
  should
  be
  only
  done
  if
  camera
  has
  been
  started
-
listen
native
Orientation
should
be
canceled
correctly
on
dispose
CameraAwesomeState
-
unlock
focus
now
restart
session
correctly
after
taking
a
photo
-
takePicture
listener
now
cannot
send
result
more
than
one
time

# 0.1.2

- [Android]
  get
  luminosity
  level
  from
  device
- [Android]
  apply
  brightness
  correction

# 0.1.1+1

- [android]
  fix
  release
  onOpenListener
  after
  emit
  result
  to
  Flutter
  platform

# 0.1.1

-
prevent
starting
camera
when
already
open
on
Flutter
side
-
stability
between
rebuilds
improved
on
Flutter
side
- [android]
  check
  size
  is
  correctly
  set
  before
  starting
  camera
-
CameraPreview
try
3
times
to
start
if
camera
is
locked (
each
try
are
1s
ellapsed)
-
Fix
android
zoom
when
taking
picture

# 0.1.0

-
image
stream
available
to
use
MLkit
or
other
image
live
processing (
Only
android)

# 0.0.2+3

-
fix
switch
camera
on
Android
with
new
update (
now
correctly
switch
ImageReader
and
cameraCharacteristics
when
switch
sensor).

# 0.0.2+1

-
comment
com.google.gms.google-services
from
example
build.gradle.
This
is
aimed
only
to
start
our
e2e
tests
on
testlabs.
Put
your
own
google-services.json
if
you
want
to
start
them
there.

# 0.0.2

-
updated
readme

# 0.0.1

-
first
version.
See
readme
for
complete
features
list
