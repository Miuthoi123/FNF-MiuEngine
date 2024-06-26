package objects;

enum abstract IconType(Int) to Int from Int //abstract so it can hold int values for the frame count
{
    var SINGLE = 0;
    var DEFAULT = 1;
    var WINNING = 2;
}

class HealthIcon extends FlxSprite
{
	public var type:IconType = DEFAULT;
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	var initialWidth:Float = 0;
	var initialHeight:Float = 0;

	public function new(char:String = 'bf', isPlayer:Bool = false, ?allowGPU:Bool = true)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		var oldIconBounceStyle:Bool = ClientPrefs.data.iconBounce == 'Old Psych';
		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + (!oldIconBounceStyle ? 12 : 10), sprTracker.y - 30);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String, ?allowGPU:Bool = true) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			var graphic = Paths.image(name, allowGPU);

			if (graphic == null)
				graphic == Paths.image('icons/icon-face');
			else if (!Paths.fileExists('images/icons/icon-face.png', IMAGE)){
				// throw "Don't delete the placeholder icon";
				trace("Warning: could not find the placeholder icon, expect crashes!");
			}
			
			loadGraphic(graphic); //Load stupidly first for getting the file size
			initialWidth = width;
			initialHeight = height;
			var width2 = width;
			if (width == 450 /*width >= 450 && width < 600 || width >= 900 && width < 1200 || width >= 1800*/) { // very complex, i fix by old way
				loadGraphic(graphic, true, Math.floor(width / 3), Math.floor(height));
				iconOffsets[0] = (width - 150) / 3;
				iconOffsets[1] = (width - 150) / 3;
				//iconOffsets[2] = (width - 150) / 3;
				for(i in 0...iconOffsets.length-1)
					iconOffsets[i] = (width - 150) / 3;
			} else { //if (width % 300 == 0 /*width >= 300 && width < 450 || width >= 600 && width < 900 || width >= 1200 && width < 1800*/) { // just same like that ^
				loadGraphic(graphic, true, Math.floor(width / 2), Math.floor(height));
				iconOffsets[0] = (width - 150) / 2;
				iconOffsets[1] = (width - 150) / 2;
			}
			updateHitbox();
			
			if(width2 == 450 /*width2 >= 450 && width2 < 600 || width2 >= 900 && width2 < 1200 || width2 >= 1800*/)
				animation.add(char, [0, 1, 2], 0, false, isPlayer);
			else //if(width2 % 300 == 0 /*width2 >= 300 && width2 < 450 || width2 >= 600 && width2 < 900 || width2 >= 1200 && width2 < 1800*/)
				animation.add(char, [0, 1], 0, false, isPlayer);

			animation.play(char);
			this.char = char;

			if(char.endsWith('-pixel')) antialiasing = false;
			else antialiasing = ClientPrefs.data.antialiasing;
		}
	}

	override function updateHitbox()
	{
		if (ClientPrefs.data.iconBounce != 'Golden Apple' && ClientPrefs.data.iconBounce != 'Dave and Bambi'
			|| Type.getClassName(Type.getClass(FlxG.state)) != 'PlayState')
		{
			super.updateHitbox();
			offset.x = iconOffsets[0];
			offset.y = iconOffsets[1];
		} else {
			super.updateHitbox();
			if (initialWidth != (150 * animation.numFrames) || initialHeight != 150) //Fixes weird icon offsets when they're HUMONGUS (sussy)
			{
				offset.x = iconOffsets[0];
				offset.y = iconOffsets[1];
			}
		}
	}
	
	public function swapOldIcon() // add back the swap bf icon to old.
	{
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	public function getCharacter():String
		return char;
}
