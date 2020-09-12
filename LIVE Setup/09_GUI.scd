/////////////////////////////////////////////////YAWN GUI/////////////////////////////////////////////////

(
~yawnW = Window("YAWN Live Setup",900@800);

~drawGui = {
	arg song = nil, sliderVals = 0!9;

	var yawnScale = ~yawnW.bounds.width/10;
	var modView,setView,offView,labelView,sliderView,numBoxesView;

	var buttMod = {Array.fill(8,{Button()})}!8;
	var buttSet = Array.fill(8,{Button()});
	var buttOff = Array.fill(8,{Button()});
	var sliders = Array.fill(9,{Slider()});
	var numBoxes = Array.fill(9,{NumberBox()});

	var rowMod = {HLayout()}!8;

	var reset = Button();

	var backgroundCol = Color.new255(30,128,180);
	var	offCol = Color.new255(255,120,50);
	var midCol = Color.yellow;
	var	onCol = Color.new255(116, 229, 80);

	~yawnW.view.removeAll;
	QtGUI.palette = QPalette.dark;

	if(song.isNil,{song = "empty"});

	////////////

	buttMod.size.do({
		arg i;

		buttMod[i].size.do({
			arg j;

			rowMod[i].add(buttMod[i][j].states_([["\n"]]));
		});
	});

	~guiInfo[song].onButts.size.do({ //instead of .size.do, just use .do and the second argument to get index numbers...
		arg i;
		var buttX, buttY, string;
		# buttX, buttY, string = ~guiInfo[song].onButts[i];

		buttMod[buttY][buttX]
		.states_([[string,Color.black,onCol]])
		.font_(Font("Menlo",12,true))
		.minHeight_(yawnScale/2)
	});

	~guiInfo[song].modButtsOn.size.do({
		arg i;
		var buttX,buttY,string;

		# buttX,buttY, string = ~guiInfo[song].modButtsOn[i];

		buttMod[buttY][buttX]
		.states_([[string,Color.black,onCol]])
		.font_(Font("Menlo",12,true))
		.minHeight_(yawnScale/2)

	});

	~guiInfo[song].modButtsMid.size.do({
		arg i;
		var buttX,buttY,string;

		# buttX,buttY,string = ~guiInfo[song].modButtsMid[i];

		buttMod[buttY][buttX]
		.states_([[string,Color.black,midCol]])
		.font_(Font("Menlo",12,true))
		.minHeight_(yawnScale/2)
	});

	modView = VLayout();
	rowMod.size.reverseDo({
		arg i;

		modView.add(rowMod[i]);
	});

	setView = VLayout();
	buttSet.size.do({
		arg i;

		if(~guiInfo[song].songButt.asArray.includes(i),{

			setView.add(
				buttSet[i]
				.states_([[
					"%\n%".format(~setList[i].song[..5],~setList[i].song[6..]),
					Color.black,
					onCol
				]])
				.font_(Font("Menlo",11,true))
				.maxWidth_(yawnScale/2),
			)
		},{
			setView.add(
				buttSet[i]
				.states_([[
					"%\n%".format(~setList[i].song[..5],~setList[i].song[6..]),
					Color.white,
				]])
				.font_(Font("Menlo",11,true))
				.maxWidth_(yawnScale/2),
			)
		})
	});

	offView = HLayout();
	buttOff.size.do({
		arg i;

		if(~guiInfo[song].offButts.asArray.includes(i),{

			offView.add(
				buttOff[i]
				.states_([["off",Color.black,offCol]])
				.maxWidth_(yawnScale/3),
				align: \center
			)
		},{
			offView.add(
				buttOff[i]
				.states_([["off",Color.black]])
				.maxWidth_(yawnScale/3),
				align: \center
			)

		})
	});

	offView.add(
		VLayout(
			reset
			.states_([["reset"]])
			.maxWidth_(yawnScale/2)
		)
		.margins_([yawnScale/9,0])
	);

	labelView = HLayout();
	8.do({
		arg i;

		case
		{i < 7 and: {~guiInfo[song].offButts.asArray.includes(i)}}{
			labelView.add(
				StaticText()
				.string_(~guiInfo[song].labels[i])
				.font_(Font("Menlo",16,true))
				.align_(\center)
				.stringColor_(offCol),
				align: \center
			)
		}
		{i < 7 and: {~guiInfo[song].offButts.asArray.includes(i).not}}{
			labelView.add(
				StaticText()
				.string_(~guiInfo[song].labels[i])
				.font_(Font("Menlo",16,true))
				.align_(\center)
				.stringColor_(Color.clear),
				align: \center
			)
		}
		{i == 7}{
			labelView.add(
				StaticText()
				.string_("click\namp")
				.font_(Font("Menlo",16,true))
				.align_(\center)
				.stringColor_(offCol),
				align: \center
			)
		}
	});

	labelView.add(
		VLayout(
			StaticText()
			.string_("mstr")
			.font_(Font("Menlo",16,true))
			.align_(\center)
			.stringColor_(offCol)
			.maxWidth_(yawnScale/2),
		)
		.margins_([yawnScale/9,0]),
		align: \center

	);

	sliderView = HLayout();
	8.do({
		arg i;

		sliderView.add(
			sliders[i]
			.minWidth_(yawnScale/2)
			.minHeight_(yawnScale*3)
			.value_(sliderVals[i])
			.action_({numBoxes[i].value_(sliders[i].value)}),
			align: \center
		)
	});

	sliderView.add(
		VLayout(
			sliders[8]
			.maxWidth_(yawnScale/2)
			.maxHeight_(yawnScale*3)
			.value_(sliderVals[8])
			.action_({numBoxes[8].value_(sliders[8].value)}),
		)
		.margins_([yawnScale/9,0]),
	);

	numBoxesView = HLayout();
	8.do({
		arg i;

		numBoxesView.add(
			numBoxes[i]
			.align_(\center)
			.value_(sliderVals[i])
			.maxWidth_(yawnScale/2),
			align: \center
		)
	});

	numBoxesView.add(
		VLayout(
			numBoxes[8]
			.align_(\center)
			.value_(sliderVals[8])
			.maxWidth_(yawnScale/2)
		)
		.margins_([yawnScale/9,0]),
		align: \center
	);

	~yawnW.background_(backgroundCol);

	~yawnW.layout_(
		VLayout(
			StaticText()
			.string_("YAWN")
			.font_(Font("Menlo",30,true))
			.stringColor_(offCol)
			.align_(\center),
			HLayout(
				modView,
				setView
				.margins_([yawnScale/9,0])
			),
			offView,
			labelView,
			sliderView,
			numBoxesView
		)
	);

	~yawnW.front;

	~yawnW.onClose_({
		AppClock.clear;
		Ndef.all.clear;
		OSCdef.freeAll;
		s.freeAll;
	});
};

"gui loaded".postln;

)
