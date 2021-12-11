import 'dart:ui';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:testbuild/model/song_model.dart';

late AnimationController _animationController;
late AnimationController _controller;
late Animation<double> _animation;

const initalHeightOfPopup = 780.0;
const hidingHeightOfPopup = 120.0;

bool isHide = false;
double otherOpacity = 1.0;

double deltaBlur = 20.0;
double bgOpacity = 0.3;

double popupOpacity = 0.65;
double popupRadius = 20.0;
double marginPopup = 20.0;
double bottomPopup = 0.0;

double diskHeight = 300.0;
Offset diskTranslateOffset = Offset.zero;

double titleTopTranslate = 0.0;
double titleFontSize = 28.0;

double sliderTopTranslate = 0.0;
double sliderScale = 1.0;

double buttonPadding = 24.0;
Offset buttonTranslateOffset = Offset.zero;

double? widthOfScreen;
double verticalDrag = 0.0;

Duration maxDuration = Duration.zero;
Duration currentDuration = Duration.zero;
PlayerState _playerState = PlayerState.STOPPED;
int? index;
late AudioPlayer _audioPlayer;
late AudioCache _audioCache;

List<SongModel> listSong = [
  SongModel(
    url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
    name: "Someone You Live 1",
    singer: "Arian Grande 1",
    image: "https://bit.ly/3ncyGiH",
  ),
  SongModel(
    url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3",
    name: "Someone You Live 2",
    singer: "Arian Grande 2",
    image: "https://bit.ly/3ncyGiH",
  ),
  SongModel(
    url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3",
    name: "Someone You Live 3",
    singer: "Arian Grande 3",
    image: "https://bit.ly/3ncyGiH",
  ),
  SongModel(
    url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
    name: "Someone You Live 4",
    singer: "Arian Grande 4",
    image: "https://bit.ly/3ncyGiH",
  ),
  SongModel(
    url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3",
    name: "Someone You Live 5",
    singer: "Arian Grande 5",
    image: "https://bit.ly/3ncyGiH",
  ),
  SongModel(
    url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3",
    name: "Someone You Live 6",
    singer: "Arian Grande 6",
    image: "https://bit.ly/3ncyGiH",
  ),
  SongModel(
    url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
    name: "Someone You Live 7",
    singer: "Arian Grande 7",
    image: "https://bit.ly/3ncyGiH",
  ),
  SongModel(
    url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3",
    name: "Someone You Live 8",
    singer: "Arian Grande 8",
    image: "https://bit.ly/3ncyGiH",
  ),
  SongModel(
    url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3",
    name: "Someone You Live 9",
    singer: "Arian Grande 9",
    image: "https://bit.ly/3ncyGiH",
  ),
];
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );
    _controller.repeat();
    _animationController.addListener(() {
      final value = _animation.value;
      updateUI(value: value);
    });

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOutCubic));

    _animationController.forward();
  }

  void updateUI({required double value}) {
    setState(() {
      // Background
      bgOpacity = (value * 0.3).clamp(0.001, 1.0);
      deltaBlur = value * 20.0;

      //Popup
      popupOpacity = 1.0 - value.clamp(0.001, 1.0 - 0.65);
      otherOpacity = (value * 1.0).clamp(0.001, 1.0);
      bottomPopup = -(1 - value) * (initalHeightOfPopup - hidingHeightOfPopup);
      marginPopup = (value * 20.0).clamp(0.001, 20.0);
      popupRadius = value * 20.0;

      // Disk
      diskHeight = (value * 300.0).clamp(60.0, 300.0);
      // Disk offset change zero to (-10, 24 from left)
      double widthScreen = widthOfScreen ?? 0.0;
      diskTranslateOffset = Offset(
          (-widthScreen / 2 + 50.0) * (1.0 - value), -20.0 * (1.0 - value));

      //Title
      titleTopTranslate = (1.0 - value) * 110.0;
      titleFontSize = (value * 28.0).clamp(22.0, 28.0);

      // Slider
      sliderTopTranslate = (1.0 - value) * 280.0;
      sliderScale = value.clamp(0.55, 1.0);

      // Pause button
      buttonPadding = (value * 24.0).clamp(12.0, 24.0);
      buttonTranslateOffset = Offset(
          (widthScreen / 2 - 50) * (1.0 - value), (-370.0 * (1.0 - value)));
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        // Drag listeners.
        onDragUpdate: (details) {
          verticalDrag += details.delta.dy;

          final value =
              1 - (verticalDrag / initalHeightOfPopup).abs().clamp(0.01, 1.0);
          updateUI(value: value);
        },
        onDragEnd: (_) {
          final value = verticalDrag / initalHeightOfPopup;
          if (value >= 0.5) {
            isHide = true;
            _animationController.forward(from: value);
          } else {
            isHide = false;
            _animationController.reverse(from: value);
          }
        },
        onStart: () {
          verticalDrag = isHide ? initalHeightOfPopup : 0.0;
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Function onDragUpdate;
  final Function onDragEnd;
  final Function onStart;

  const MyHomePage(
      {Key? key,
      required this.onDragUpdate,
      required this.onDragEnd,
      required this.onStart})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    widthOfScreen = MediaQuery.of(context).size.width;
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (BuildContext context, Widget? child) {
          return Stack(
            children: [
              Background(),
              PopUp(
                onDragEnd: widget.onDragEnd,
                onDragUpdate: widget.onDragUpdate,
                onStart: widget.onStart,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildBlurBackground() {
    return Transform.translate(
        offset: Offset(0.0, -sliderTopTranslate),
        child: Transform.scale(
          scale: sliderScale,
          child: Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: deltaBlur, sigmaY: deltaBlur),
              child: Container(
                color: Colors.black.withOpacity(bgOpacity),
              ),
            ),
          ),
        ));
  }
}

class Background extends StatefulWidget {
  const Background({Key? key}) : super(key: key);

  @override
  _BackgroundState createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemBuilder: (context, index) {
            return AudioWidget(
              songModel: listSong[index],
              index: index,
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 10,
            );
          },
          itemCount: listSong.length,
        ),
      ),
    );
  }
}

class Action extends StatefulWidget {
  const Action({Key? key}) : super(key: key);

  @override
  _ActionState createState() => _ActionState();
}

class _ActionState extends State<Action> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset("assets/images/icon_share.png"),
          Image.asset("assets/images/icon_add.png"),
          Image.asset("assets/images/icon_music.png"),
          Image.asset("assets/images/icon_download.png"),
        ],
      ),
    );
  }
}

class Disk extends StatefulWidget {
  const Disk({Key? key}) : super(key: key);

  @override
  _DiskState createState() => _DiskState();
}

class _DiskState extends State<Disk> {
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
        offset: diskTranslateOffset,
        child: InkWell(
          onTap: () {
            isHide = !isHide;
            if (isHide) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }
          },
          child: Stack(children: [
            RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
              child: Image(
                image: const AssetImage("assets/images/song_avatar.png"),
                width: diskHeight,
                height: diskHeight,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
                child: Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: otherOpacity,
                child: CircleAvatar(
                  radius: 26.0,
                  backgroundColor: Colors.white.withOpacity(0.6),
                ),
              ),
            ))
          ]),
        ));
  }
}

class PopUp extends StatefulWidget {
  final Function onDragUpdate;
  final Function onDragEnd;
  final Function onStart;
  const PopUp(
      {Key? key,
      required this.onDragUpdate,
      required this.onDragEnd,
      required this.onStart})
      : super(key: key);

  @override
  _PopUpState createState() => _PopUpState();
}

class _PopUpState extends State<PopUp> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottomPopup,
      left: 0.0,
      right: 0.0,
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            GestureDetector(
              onVerticalDragUpdate: (details) {
                widget.onDragUpdate(details);
              },
              onVerticalDragEnd: (details) {
                widget.onDragEnd(details);
              },
              onVerticalDragStart: (details) {
                widget.onStart();
              },
              child: Container(
                height: initalHeightOfPopup,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(popupOpacity)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 40.0,
                    ),
                    Disk(),
                    InfoSing(),
                    Opacity(opacity: otherOpacity, child: Action()),
                    const SizedBox(
                      height: 12.0,
                    ),
                    Slider(),
                    ControlAction()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Slider extends StatefulWidget {
  const Slider({Key? key}) : super(key: key);

  @override
  _SliderState createState() => _SliderState();
}

class _SliderState extends State<Slider> {
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0.0, -sliderTopTranslate),
      child: Transform.scale(
        scale: sliderScale,
        child: SizedBox(
          height: 60.0,
          child: Stack(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: ProgressBar(
                  progress: currentDuration,
                  total: maxDuration,
                  onSeek: (duration) async {
                    _audioPlayer.seek(duration);
                    _audioPlayer.onAudioPositionChanged.listen((Duration p) {
                      setState(() {
                        currentDuration = p;
                        _playerState = PlayerState.PLAYING;
                      });
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoSing extends StatefulWidget {
  const InfoSing({Key? key}) : super(key: key);

  @override
  _InfoSingState createState() => _InfoSingState();
}

class _InfoSingState extends State<InfoSing> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 35.0),
      child: Column(
        children: [
          Transform.translate(
            offset: Offset(0.0, -titleTopTranslate),
            child: Text(
              listSong[index ?? 0].name ?? '',
              style: TextStyle(
                  fontSize: titleFontSize, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Opacity(
            opacity: otherOpacity,
            child: Text(
              listSong[index ?? 0].singer ?? '',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.redAccent),
            ),
          ),
          const SizedBox(
            height: 24.0,
          ),
        ],
      ),
    );
  }
}

class ControlAction extends StatefulWidget {
  const ControlAction({Key? key}) : super(key: key);

  @override
  _ControlActionState createState() => _ControlActionState();
}

class _ControlActionState extends State<ControlAction> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, top: 24.0, right: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Opacity(
            opacity: otherOpacity,
            child: const Image(
              image: AssetImage("assets/images/icon_shuffle.png"),
              height: 30.0,
            ),
          ),
          Opacity(
            opacity: otherOpacity,
            child: const Image(
              image: AssetImage("assets/images/icon_back.png"),
              height: 30.0,
            ),
          ),
          Transform.translate(
            offset: buttonTranslateOffset,
            child: ClipOval(
              child: Container(
                  color: const Color(0xFFFF5753),
                  child: Padding(
                    padding: EdgeInsets.all(buttonPadding),
                    child: GestureDetector(
                      onTap: () async {
                        if (_playerState == PlayerState.PLAYING) {
                          final playerResult = await _audioPlayer.pause();
                          if (playerResult == 1) {
                            setState(() {
                              _playerState = PlayerState.PAUSED;
                            });
                          }
                        } else if (_playerState == PlayerState.PAUSED) {
                          final playerResult = await _audioPlayer.resume();
                          if (playerResult == 1) {
                            setState(() {
                              _playerState = PlayerState.PLAYING;
                            });
                          }
                        }
                      },
                      child: _playerState == PlayerState.PAUSED
                          ? const Icon(
                              Icons.play_circle,
                              size: 32,
                            )
                          : const Image(
                              image: AssetImage("assets/images/icon_play.png"),
                              height: 32,
                            ),
                    ),
                  )),
            ),
          ),
          Opacity(
            opacity: otherOpacity,
            child: const Image(
              image: AssetImage("assets/images/icon_next.png"),
              height: 30.0,
            ),
          ),
          Opacity(
            opacity: otherOpacity,
            child: const Image(
              image: AssetImage("assets/images/icon_repeat.png"),
              height: 30.0,
            ),
          ),
        ],
      ),
    );
  }
}

class AudioWidget extends StatefulWidget {
  final SongModel songModel;
  final bool isAsset;
  final int index;

  const AudioWidget({
    Key? key,
    required this.songModel,
    required this.index,
    this.isAsset = false,
  }) : super(key: key);

  @override
  _AudioWidgetState createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  bool get _isLocal => !widget.songModel.url!.contains('https');
  _playPause() async {
    if (_playerState == PlayerState.PLAYING) {
      final playerResult = await _audioPlayer.pause();
      if (playerResult == 1) {
        setState(() {
          _playerState = PlayerState.PAUSED;
        });
      }
    } else if (_playerState == PlayerState.PAUSED) {
      final playerResult = await _audioPlayer.resume();
      if (playerResult == 1) {
        setState(() {
          _playerState = PlayerState.PLAYING;
        });
      }
    } else {
      if (widget.isAsset) {
        _audioPlayer = await _audioCache.play(widget.songModel.url!);
        setState(() {
          _playerState = PlayerState.PLAYING;
        });
      } else {
        final playerResult =
            await _audioPlayer.play(widget.songModel.url!, isLocal: _isLocal);
        if (playerResult == 1) {
          setState(() {
            _playerState = PlayerState.PLAYING;
          });
        }
      }
    }
    setState(() {
      index = widget.index;
      print(index);
    });
  }

  @override
  void initState() {
    _audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
    _audioCache = AudioCache(fixedPlayer: _audioPlayer);
    AudioPlayer.logEnabled = true;
    _audioPlayer.onPlayerError.listen((msg) {
      setState(() {
        _playerState = PlayerState.STOPPED;
      });
    });
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        maxDuration = d;
        //  print(maxDuration);
        _playerState = PlayerState.PLAYING;
      });
    });
    _audioPlayer.onAudioPositionChanged.listen((Duration p) {
      setState(() {
        currentDuration = p;
        print(currentDuration);
        _playerState = PlayerState.PLAYING;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              "#${(widget.index + 1)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.network(
                widget.songModel.image!,
                height: 50,
                width: 50,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.songModel.name ?? "",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  widget.songModel.singer ?? "",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.redAccent),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
