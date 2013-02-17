// Generated by CoffeeScript 1.3.3
(function() {
  var AssetManager, Building, BuildingPortion, BuildingTileSet, CanvasRenderer, Game, IsoGame, IsometricGrid, Sprite, UI, assetManager, game, init, mapData,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    _this = this,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  AssetManager = (function() {

    function AssetManager() {
      this.cache = {};
    }

    AssetManager.prototype.addAsset = function(image, tag) {
      this.cache[tag] = image;
      return console.log('adding ' + tag);
    };

    AssetManager.prototype.getAsset = function(tag) {
      console.log('getting ' + tag);
      return this.cache[tag];
    };

    return AssetManager;

  })();

  CanvasRenderer = (function() {

    function CanvasRenderer() {
      this.resizeCanvas = __bind(this.resizeCanvas, this);

      this.fixSizeToScreen = __bind(this.fixSizeToScreen, this);

      this.setSize = __bind(this.setSize, this);

      this.clear = __bind(this.clear, this);
      this.canvas = document.createElement('canvas');
      $('#container').append(this.canvas);
      $('#container canvas')[0].id = 'canvas';
      this.context = this.canvas.getContext("2d");
    }

    CanvasRenderer.prototype.clear = function(colour) {
      this.context.fillStyle = colour;
      return this.context.fillRect(0, 0, this.canvas.width, this.canvas.height);
    };

    CanvasRenderer.prototype.setSize = function(width, height) {
      this.canvas.width = width;
      return this.canvas.height = height;
    };

    CanvasRenderer.prototype.fixSizeToScreen = function() {
      window.addEventListener('resize', this.resizeCanvas, false);
      return this.resizeCanvas();
    };

    CanvasRenderer.prototype.resizeCanvas = function() {
      return this.setSize(window.innerWidth, window.innerHeight);
    };

    return CanvasRenderer;

  })();

  Building = (function() {

    function Building(sprite, width, height, id, drawWidth, drawHeight, row, col, z) {
      this.sprite = sprite;
      this.width = width;
      this.height = height;
      this.id = id;
      this.drawWidth = drawWidth;
      this.drawHeight = drawHeight;
      this.row = row;
      this.col = col;
      this.z = z;
    }

    return Building;

  })();

  BuildingPortion = (function() {

    function BuildingPortion(building, row, col, z) {
      this.building = building;
      this.row = row;
      this.col = col;
      this.z = z;
      this.sprite = this.building.sprite;
    }

    return BuildingPortion;

  })();

  IsometricGrid = (function() {

    IsometricGrid.renderer = null;

    function IsometricGrid(parameters) {
      this.sortZ = __bind(this.sortZ, this);

      this.isArray = __bind(this.isArray, this);

      this.handleMouseDown = __bind(this.handleMouseDown, this);

      this.handleMouseUp = __bind(this.handleMouseUp, this);

      this.handleDrag = __bind(this.handleDrag, this);

      this.handleKeyDown = __bind(this.handleKeyDown, this);

      this.checkIfTileIsFree = __bind(this.checkIfTileIsFree, this);

      this.placeBuilding = __bind(this.placeBuilding, this);

      this.getBuildingLocation = __bind(this.getBuildingLocation, this);

      this.setZoom = __bind(this.setZoom, this);

      var _ref, _ref1, _ref2, _ref3,
        _this = this;
      this.tileMap = (_ref = parameters.tileMap) != null ? _ref : [];
      this.width = (_ref1 = parameters.width) != null ? _ref1 : 4;
      this.height = (_ref2 = parameters.height) != null ? _ref2 : 4;
      this.defaultTile = (_ref3 = parameters.defaultTile) != null ? _ref3 : null;
      if (this.defaultTile !== null) {
        this.tileWidth = this.defaultTile.width;
        this.tileHeight = this.defaultTile.height;
      }
      this.scrollPosition = {
        x: 0,
        y: 0
      };
      this.zoom = 1;
      this.tileWidth = this.defaultTile.width * this.zoom;
      this.tileHeight = this.defaultTile.height * this.zoom;
      this.scrollPosition.y -= this.height * this.zoom + this.scrollPosition.y;
      this.scrollPosition.x -= this.width * this.zoom + this.scrollPosition.x;
      this.mouseOverTile = null;
      this.dragHelper = {
        active: false,
        x: 0,
        y: 0
      };
      this.Keys = {
        UP: 38,
        DOWN: 40,
        LEFT: 37,
        RIGHT: 39,
        W: 87,
        A: 65,
        S: 83,
        D: 68,
        Z: 90,
        X: 88,
        R: 82
      };
      window.addEventListener('keydown', function(e) {
        return _this.handleKeyDown(e);
      }, false);
      window.addEventListener('mousedown', function(e) {
        if (e.target.id === 'canvas') {
          return _this.handleMouseDown(e);
        }
      }, false);
      window.addEventListener('mousemove', function(e) {
        if (e.target.id === 'canvas') {
          return _this.handleDrag(e);
        }
      }, false);
      window.addEventListener('mouseup', function(e) {
        if (e.target.id === 'canvas') {
          return _this.handleMouseUp(e);
        }
      }, false);
    }

    IsometricGrid.prototype.translatePixelsToMatrix = function(x, y) {
      var col, gridOffsetX, gridOffsetY, row;
      gridOffsetY = this.height * this.zoom + this.scrollPosition.y;
      gridOffsetX = this.width * this.zoom;
      gridOffsetX += (IsometricGrid.renderer.canvas.width / 2) - (this.tileWidth * this.zoom / 2) + this.scrollPosition.x;
      col = (2 * (y - gridOffsetY) - x + gridOffsetX) / 2;
      row = x + col - gridOffsetX - this.tileHeight;
      col = Math.round(col / this.tileHeight);
      row = Math.round(row / this.tileHeight);
      return {
        row: row,
        col: col
      };
    };

    IsometricGrid.prototype.setZoom = function(value) {
      this.zoom = value;
      this.tileWidth = this.defaultTile.width * this.zoom;
      return this.tileHeight = this.defaultTile.height * this.zoom;
    };

    IsometricGrid.prototype.draw = function() {
      var buildingPosition, col, colCount, i, pos_BL, pos_BR, pos_TL, pos_TR, row, rowCount, startCol, startRow, startX, startY, xpos, ypos, _i, _ref, _results;
      pos_TL = this.translatePixelsToMatrix(1, 1);
      pos_BL = this.translatePixelsToMatrix(1, IsometricGrid.renderer.canvas.height);
      pos_TR = this.translatePixelsToMatrix(IsometricGrid.renderer.canvas.width, 1);
      pos_BR = this.translatePixelsToMatrix(IsometricGrid.renderer.canvas.width, IsometricGrid.renderer.canvas.height);
      startRow = pos_TL.row;
      startCol = pos_TR.col;
      rowCount = pos_BR.row + 1;
      colCount = pos_BL.col + 1;
      if (startRow < 0) {
        startRow = 0;
      }
      if (startCol < 0) {
        startCol = 0;
      }
      if (rowCount > this.width) {
        rowCount = this.width;
      }
      if (colCount > this.height) {
        colCount = this.height;
      }
      if (IsoGame.settings.techStats) {
        $("#rowStart").html(startRow);
        $("#colStart").html(startRow);
        $("#rowEnd").html(rowCount);
        $("#colEnd").html(colCount);
        if (this.mouseOverTile !== null) {
          $("#arraySize").html(this.mouseOverTile.buildings.length);
          if (this.mouseOverTile.tilePropeties.occupied) {
            $("#occupied").html('true');
          } else {
            $("#occupied").html('false');
          }
        } else {
          $("#arraySize").html('');
          $("#occupied").html('');
        }
      }
      _results = [];
      for (row = _i = startRow, _ref = rowCount - 1; startRow <= _ref ? _i <= _ref : _i >= _ref; row = startRow <= _ref ? ++_i : --_i) {
        _results.push((function() {
          var _j, _ref1, _results1;
          _results1 = [];
          for (col = _j = startCol, _ref1 = colCount - 1; startCol <= _ref1 ? _j <= _ref1 : _j >= _ref1; col = startCol <= _ref1 ? ++_j : --_j) {
            xpos = (row - col) * this.tileHeight + (this.width * this.zoom);
            xpos += (IsometricGrid.renderer.canvas.width / 2) - (this.tileWidth / 2 * this.zoom) + this.scrollPosition.x;
            ypos = (row + col) * (this.tileHeight / 2) + (this.height * this.zoom) + this.scrollPosition.y;
            startX = xpos;
            startY = ypos;
            if (Math.round(xpos) + this.tileWidth >= 0 && Math.round(ypos) + this.tileHeight >= 0 && Math.round(xpos) <= IsometricGrid.renderer.canvas.width && Math.round(ypos) <= IsometricGrid.renderer.canvas.height) {
              IsometricGrid.renderer.context.drawImage(this.defaultTile.spritesheet, Math.round(xpos), Math.round(ypos), this.tileWidth, this.tileHeight);
              if (typeof this.tileMap[row] !== 'undefined' && typeof this.tileMap[row][col] !== 'undefined') {
                if (this.isArray(this.tileMap[row][col].buildings)) {
                  startX += this.tileWidth * 0.5;
                  startY += this.tileHeight;
                  _results1.push((function() {
                    var _k, _ref2, _results2;
                    _results2 = [];
                    for (i = _k = 0, _ref2 = this.tileMap[row][col].buildings.length - 1; 0 <= _ref2 ? _k <= _ref2 : _k >= _ref2; i = 0 <= _ref2 ? ++_k : --_k) {
                      buildingPosition = this.getBuildingLocation(this.tileMap[row][col].buildings[i]);
                      this.tileMap[row][col].buildings[i].sprite.setPosition(buildingPosition.x, buildingPosition.y);
                      IsometricGrid.renderer.context.save();
                      IsometricGrid.renderer.context.strokeStyle = "transparent";
                      IsometricGrid.renderer.context.beginPath();
                      IsometricGrid.renderer.context.moveTo(Math.round(startX), Math.round(startY));
                      IsometricGrid.renderer.context.lineTo(Math.round(startX) + 0.5 * this.tileWidth, Math.round(startY) - 0.5 * this.tileHeight);
                      IsometricGrid.renderer.context.lineTo(Math.round(startX), Math.round(startY) - this.tileHeight);
                      IsometricGrid.renderer.context.lineTo(Math.round(startX) - 0.5 * this.tileWidth, Math.round(startY) - 0.5 * this.tileHeight);
                      IsometricGrid.renderer.context.lineTo(Math.round(startX), Math.round(startY));
                      IsometricGrid.renderer.context.stroke();
                      IsometricGrid.renderer.context.clip();
                      this.tileMap[row][col].buildings[i].sprite.draw();
                      _results2.push(IsometricGrid.renderer.context.restore());
                    }
                    return _results2;
                  }).call(this));
                } else {
                  _results1.push(void 0);
                }
              } else {
                _results1.push(void 0);
              }
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    IsometricGrid.prototype.getBuildingLocation = function(building) {
      var xpos, ypos;
      xpos = (building.row - building.col) * this.tileHeight + (this.width * this.zoom);
      xpos += (IsometricGrid.renderer.canvas.width / 2) - (this.tileWidth / 2 * this.zoom) + this.scrollPosition.x;
      ypos = (building.row + building.col) * (this.tileHeight / 2) + (this.height * this.zoom) + this.scrollPosition.y;
      ypos -= (building.sprite.height * this.zoom) - this.tileHeight;
      xpos -= ((building.sprite.width * this.zoom) / 2) - (this.tileWidth / 2);
      return {
        x: xpos,
        y: ypos
      };
    };

    IsometricGrid.prototype.placeBuilding = function(x, y, data) {
      var i, j, obj, pos, sprite, _i, _ref, _ref1, _results;
      pos = this.translatePixelsToMatrix(x, y);
      sprite = new Sprite({
        spritesheet: data.spritesheet,
        width: data.pixelWidth,
        height: data.pixelHeight,
        offsetX: data.offsetX,
        offsetY: data.offsetY,
        frames: data.frames,
        duration: data.duration
      });
      obj = new Building(sprite, data.width, data.height, data.id, data.drawWidth, data.drawHeight);
      if (this.checkIfTileIsFree(obj, pos.row, pos.col)) {
        _results = [];
        for (i = _i = _ref = (pos.row + 1) - obj.drawWidth, _ref1 = pos.row; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; i = _ref <= _ref1 ? ++_i : --_i) {
          _results.push((function() {
            var _j, _ref2, _ref3, _results1;
            _results1 = [];
            for (j = _j = _ref2 = (pos.col + 1) - obj.drawHeight, _ref3 = pos.col; _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; j = _ref2 <= _ref3 ? ++_j : --_j) {
              if (this.tileMap[i] === void 0) {
                this.tileMap[i] = [];
              }
              if (i === pos.row && j === pos.col) {
                if (this.tileMap[i][j] === void 0) {
                  this.tileMap[i][j] = {
                    buildings: [],
                    tilePropeties: {}
                  };
                }
                obj.row = i;
                obj.col = j;
                obj.z = i + j;
                this.tileMap[i][j].buildings.push(obj);
                this.tileMap[i][j].buildings.sort(this.sortZ);
                _results1.push(this.tileMap[i][j].tilePropeties["occupied"] = true);
              } else {
                if (this.tileMap[i][j] === void 0) {
                  this.tileMap[i][j] = {
                    buildings: [],
                    tilePropeties: {}
                  };
                }
                this.tileMap[i][j].buildings.push(new BuildingPortion(obj, pos.row, pos.col, pos.col + pos.row));
                this.tileMap[i][j].buildings.sort(this.sortZ);
                if (Math.abs(i - pos.row) < obj.height && Math.abs(j - pos.col) < obj.width) {
                  _results1.push(this.tileMap[i][j].tilePropeties["occupied"] = true);
                } else {
                  _results1.push(void 0);
                }
              }
            }
            return _results1;
          }).call(this));
        }
        return _results;
      }
    };

    IsometricGrid.prototype.checkIfTileIsFree = function(obj, row, col) {
      var i, j, _i, _j, _ref, _ref1;
      for (i = _i = _ref = (row + 1) - obj.width; _ref <= row ? _i <= row : _i >= row; i = _ref <= row ? ++_i : --_i) {
        for (j = _j = _ref1 = (col + 1) - obj.height; _ref1 <= col ? _j <= col : _j >= col; j = _ref1 <= col ? ++_j : --_j) {
          if (this.tileMap[i] !== void 0 && this.tileMap[i][j] !== void 0) {
            if (this.tileMap[i][j].tilePropeties.occupied === true) {
              return false;
            }
          }
        }
      }
      return true;
    };

    IsometricGrid.prototype.handleKeyDown = function(e) {
      switch (e.keyCode) {
        case this.Keys.UP:
        case this.Keys.W:
          return this.scrollPosition.y -= 20;
        case this.Keys.DOWN:
        case this.Keys.S:
          return this.scrollPosition.y += 20;
        case this.Keys.LEFT:
        case this.Keys.A:
          return this.scrollPosition.x -= 20;
        case this.Keys.RIGHT:
        case this.Keys.D:
          return this.scrollPosition.x += 20;
      }
    };

    IsometricGrid.prototype.handleDrag = function(e) {
      var tile, x, y;
      e.preventDefault();
      if (this.dragHelper.active) {
        x = e.clientX;
        y = e.clientY;
        this.scrollPosition.x = Math.round(x - this.dragHelper.x);
        return this.scrollPosition.y = Math.round(y - this.dragHelper.y);
      } else {
        tile = this.translatePixelsToMatrix(e.clientX, e.clientY);
        if (typeof this.tileMap[tile.row] !== 'undefined' && typeof this.tileMap[tile.row][tile.col] !== 'undefined') {
          return this.mouseOverTile = this.tileMap[tile.row][tile.col];
        }
      }
    };

    IsometricGrid.prototype.handleMouseUp = function(e) {
      e.preventDefault();
      return this.dragHelper.active = false;
    };

    IsometricGrid.prototype.handleMouseDown = function(e) {
      var x, y;
      e.preventDefault();
      x = e.clientX;
      y = e.clientY;
      this.dragHelper.active = true;
      this.dragHelper.x = x - this.scrollPosition.x;
      return this.dragHelper.y = y - this.scrollPosition.y;
    };

    IsometricGrid.prototype.isArray = function(obj) {
      return Object.prototype.toString.call(obj) === '[object Array]';
    };

    IsometricGrid.prototype.sortZ = function(a, b) {
      if (a.z < b.z) {
        return -1;
      }
      if (a.z > b.z) {
        return 1;
      }
      return 0;
    };

    return IsometricGrid;

  })();

  Sprite = (function() {

    Sprite.renderer = null;

    function Sprite(parameters) {
      this.draw = __bind(this.draw, this);

      this.nextFrame = __bind(this.nextFrame, this);

      this.animate = __bind(this.animate, this);

      this.setPosition = __bind(this.setPosition, this);

      var _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8;
      this.spritesheet = (_ref = parameters.spritesheet) != null ? _ref : console.log('ERROR - no spritesheet selected');
      this.posX = (_ref1 = parameters.x) != null ? _ref1 : 0;
      this.posY = (_ref2 = parameters.y) != null ? _ref2 : 0;
      this.width = (_ref3 = parameters.width) != null ? _ref3 : this.spritesheet.width;
      this.height = (_ref4 = parameters.height) != null ? _ref4 : this.spritesheet.height;
      this.offsetX = (_ref5 = parameters.offsetX) != null ? _ref5 : 0;
      this.offsetY = (_ref6 = parameters.offsetY) != null ? _ref6 : 0;
      this.frames = (_ref7 = parameters.frames) != null ? _ref7 : 0;
      this.duration = (_ref8 = parameters.duration) != null ? _ref8 : 0;
      this.currentFrame = 0;
      this.currentTime = (new Date()).getTime();
      this.ftime = this.currentTime + (this.duration / this.frames);
    }

    Sprite.prototype.setPosition = function(x, y) {
      this.posX = x;
      return this.posY = y;
    };

    Sprite.prototype.animate = function() {
      if (this.currentTime > this.ftime) {
        this.nextFrame();
      }
      this.currentTime = (new Date()).getTime();
      return this.draw();
    };

    Sprite.prototype.nextFrame = function() {
      var d;
      if (this.duration > 0) {
        d = new Date();
        this.ftime = d.getTime() + (this.duration / this.frames);
        this.offsetX = this.width * this.currentFrame;
        if (this.currentFrame === this.frames - 1) {
          return this.currentFrame = 0;
        } else {
          return this.currentFrame++;
        }
      }
    };

    Sprite.prototype.draw = function() {
      return Sprite.renderer.context.drawImage(this.spritesheet, this.offsetX, this.offsetY, this.width, this.height, this.posX, this.posY, this.width * game.grid.zoom, this.height * game.grid.zoom);
    };

    return Sprite;

  })();

  BuildingTileSet = (function() {

    function BuildingTileSet(spritesheet) {
      this.spritesheet = spritesheet;
      this.getBuilding = __bind(this.getBuilding, this);

      this.buildings = new Array();
    }

    BuildingTileSet.prototype.getBuilding = function(lineNumber) {
      return this.buildings[lineNumber];
    };

    return BuildingTileSet;

  })();

  IsoGame = (function() {

    IsoGame.settings = {
      techStats: false
    };

    function IsoGame() {
      this.displayTech = __bind(this.displayTech, this);

      this.displayFps = __bind(this.displayFps, this);

      this.createRenderer = __bind(this.createRenderer, this);

      this.animloop = __bind(this.animloop, this);
      this.renderer = null;
      this.frameCount = 0;
      this.fps = 0;
      this.startTime = (new Date()).getTime();
    }

    IsoGame.prototype.animloop = function() {
      var currentTime;
      requestAnimFrame(this.animloop);
      this.frameCount++;
      currentTime = (new Date()).getTime();
      if (currentTime - this.startTime > 1000) {
        this.fps = this.frameCount;
        this.frameCount = 0;
        return this.startTime = (new Date()).getTime();
      }
    };

    IsoGame.prototype.createRenderer = function(type) {
      if (type === 'canvas') {
        this.renderer = new CanvasRenderer;
        Sprite.renderer = this.renderer;
        return IsometricGrid.renderer = this.renderer;
      } else {

      }
    };

    IsoGame.prototype.displayFps = function() {
      return $("#fps").html(this.fps);
    };

    IsoGame.prototype.displayTech = function(value) {
      if (value) {
        $("#stats").css("visibility", "visible");
        return IsoGame.settings.techStats = true;
      } else {
        $("#stats").css("visibility", "hidden");
        return IsoGame.settings.techStats = false;
      }
    };

    return IsoGame;

  })();

  assetManager = null;

  game = null;

  mapData = {};

  init = function() {
    /*
    
      
    
      This init function is also called on the start screen, so remove this script 
      from start_screen header. 
    
      Make a new script which only loads on start_screen. This script will collect info settings default
      tile etc. When user clicks submit all this data is sent to the servor and then the servor does 
      a self.redirect('editor/?r=' + varable ) etc.
    */

    var loader, query_columns, query_defaultTile_name, query_rows;
    query_rows = $.query.get("r");
    query_columns = $.query.get("c");
    query_defaultTile_name = $.query.get("t");
    if (!assetManager) {
      assetManager = new AssetManager();
      loader = new PxLoader();
      assetManager.addAsset(loader.addImage("default_tile_img?image_name=" + query_defaultTile_name), query_defaultTile_name);
      loader.addCompletionListener(function() {
        var defaultTile, numCols, numRows;
        numRows = parseInt(query_rows) || 4;
        numCols = parseInt(query_columns) || 4;
        defaultTile = query_defaultTile_name || 'grass';
        return game = new Game(numRows, numCols, defaultTile);
      });
      return loader.start();
    }
  };

  $(document).ready(init);

  Game = (function(_super) {

    __extends(Game, _super);

    function Game(numberRows, numberCols, tile) {
      this.animloop = __bind(this.animloop, this);

      var defaultTile, spritesheet;
      Game.__super__.constructor.apply(this, arguments);
      this.createRenderer('canvas');
      this.renderer.fixSizeToScreen();
      this.displayTech(true);
      $("#toolbar").css("visibility", "visible");
      this.UI = new UI();
      defaultTile = new Sprite({
        spritesheet: assetManager.getAsset(tile)
      });
      this.grid = new IsometricGrid({
        width: numberRows,
        height: numberCols,
        defaultTile: defaultTile
      });
      spritesheet = assetManager.getAsset('sprite1');
      this.animloop();
    }

    Game.prototype.animloop = function() {
      Game.__super__.animloop.apply(this, arguments);
      this.renderer.clear('#FFFFFF');
      this.grid.draw();
      return this.displayFps();
    };

    return Game;

  })(IsoGame);

  UI = (function() {

    function UI(parameters) {
      this.UIMouseDown = __bind(this.UIMouseDown, this);

      this.loadBuildingData = __bind(this.loadBuildingData, this);

      this.uploadBTS = __bind(this.uploadBTS, this);

      this.changeProperties = __bind(this.changeProperties, this);

      this.displayProperties = __bind(this.displayProperties, this);

      this.displayBuildingSelectonDialog = __bind(this.displayBuildingSelectonDialog, this);

      this.setupToolbar = __bind(this.setupToolbar, this);

      var _this = this;
      window.addEventListener('mousedown', function(e) {
        var button;
        button = e.which || e.button;
        if (button === 1) {
          return _this.UIMouseDown(e);
        }
      }, false);
      this.bts_json = null;
      this.bts_spritesheet = null;
      this.bts_spritesheet_file = null;
      this.toolSelect = null;
      this.selectedBuilding = null;
      this.zoomLevel = 1;
      this.selectedThumb = null;
      this.buildingSelectionToolBarVisible = false;
      this.setupToolbar();
    }

    UI.prototype.setupToolbar = function() {
      var flag, _i, _results,
        _this = this;
      $("#toolbar ul").append('<li id="zoomIn"></li>');
      $('#zoomIn').css('background', 'url(image/zoomin.png) no-repeat');
      $("#toolbar ul").append('<li id="zoomOut"></li>');
      $('#zoomOut').css('background', 'url(image/zoomout.png) no-repeat');
      $("#toolbar ul").append('<li id="demolish"></li>');
      $('#demolish').css('background', 'url(image/delete.png) no-repeat');
      _results = [];
      for (flag = _i = 1; _i <= 5; flag = ++_i) {
        $("#toolbar ul").append("<li id='iconSet" + flag + "'></li>");
        $("#iconSet" + flag).css("background", "url(image/flag" + flag + ".png) no-repeat");
        _results.push($("#iconSet" + flag).rightClick(function(e) {
          return _this.displayBuildingSelectonDialog(e.target.id);
        }));
      }
      return _results;
    };

    UI.prototype.displayBuildingSelectonDialog = function(id) {
      var buildingTileSet, flagNumber, handleJSONSelection, handleSpritesheetSelection,
        _this = this;
      $("#setBuildingTileSet").css("visibility", "visible");
      $("#numberFrames").prop('disabled', true);
      flagNumber = id.substring(7, id.length);
      buildingTileSet = void 0;
      handleJSONSelection = function(evt) {
        var f, files, reader;
        files = evt.target.files;
        f = files[0];
        reader = new FileReader();
        reader.onload = (function(theFile) {
          return function(e) {
            var JsonObj, frame, framename, m, newframes, newname, oldframes, parsedJSON;
            JsonObj = e.target.result;
            console.log(JsonObj);
            parsedJSON = JSON.parse(JsonObj);
            oldframes = parsedJSON.frames;
            newframes = {};
            for (framename in oldframes) {
              m = framename.match(/^(.+?)(\d*)\.png$/);
              newname = m[1];
              frame = oldframes[framename];
              if (!(newname in newframes)) {
                newframes[newname] = {
                  size: frame.sourceSize,
                  tile: {
                    baseW: 0,
                    baseH: 0,
                    drawW: 0,
                    drawH: 0
                  }
                };
                if (m[2]) {
                  newframes[newname] = {
                    size: frame.sourceSize,
                    tile: {
                      baseW: 0,
                      baseH: 0,
                      drawW: 0,
                      drawH: 0
                    },
                    animation: {
                      frames: 0,
                      speed: 0
                    },
                    frames: {}
                  };
                }
              }
              if (m[2]) {
                newframes[newname].frames["frame" + m[2]] = frame.frame;
              } else {
                newframes[newname].frame = frame.frame;
              }
            }
            parsedJSON.frames = newframes;
            delete parsedJSON.meta;
            parsedJSON.name = parsedJSON.frames;
            delete parsedJSON.frames;
            _.each(parsedJSON.name, function(val) {
              if (_.has(val, 'animation')) {
                return val.animation.frames = _.size(val.frames);
              }
            });
            JsonObj = JSON.stringify(parsedJSON, null, 4);
            console.log(JsonObj);
            return _this.bts_json = parsedJSON;
          };
        })(f);
        return reader.readAsText(f, 'UTF-8');
      };
      document.getElementById('upload_JSON').addEventListener('change', handleJSONSelection, false);
      handleSpritesheetSelection = function(evt) {
        var f, files, reader;
        files = evt.target.files;
        f = files[0];
        _this.bts_spritesheet_file = f;
        reader = new FileReader();
        reader.onload = (function(theFile) {
          return function(e) {
            return _this.bts_spritesheet = e.target.result;
          };
        })(f);
        return reader.readAsDataURL(f);
      };
      document.getElementById('upload_spritesheet').addEventListener('change', handleSpritesheetSelection, false);
      $('#display_building_thumbs').click(function() {
        var buildingFrame, buildingNames, _results;
        buildingNames = _this.bts_json.name;
        _results = [];
        for (buildingFrame in buildingNames) {
          _results.push((function(buildingFrame) {
            var h, overlay, w, x, y;
            if (buildingNames[buildingFrame].hasOwnProperty("frame")) {
              w = buildingNames[buildingFrame]["size"]["w"];
              h = buildingNames[buildingFrame]["size"]["h"];
              x = buildingNames[buildingFrame]["frame"]["x"];
              y = buildingNames[buildingFrame]["frame"]["y"];
              $('#building_thumb_view').append("<div class='tile_wrap' id='bt-" + buildingFrame + "' style='                                              background-image:url(" + _this.bts_spritesheet + ");                                              background-position:-" + x + "px -" + y + "px;                                              width:" + w + "px;                                               height:" + h + "px;                                              '>" + buildingFrame + "</div>");
            }
            if (buildingNames[buildingFrame].hasOwnProperty("frames")) {
              w = buildingNames[buildingFrame]["size"]["w"];
              h = buildingNames[buildingFrame]["size"]["h"];
              x = buildingNames[buildingFrame]["frames"]["frame1"]["x"];
              y = buildingNames[buildingFrame]["frames"]["frame1"]["y"];
              $('#building_thumb_view').append("<div class='tile_wrap' id='bt-" + buildingFrame + "' style='                                              background-image:url(" + _this.bts_spritesheet + ");                                              background-position:-" + x + "px -" + y + "px;                                              width:" + w + "px;                                               height:" + h + "px;                                              '>" + buildingFrame + "</div>");
            }
            overlay = $('.tile_wrap');
            return $("#bt-" + buildingFrame).click(function() {
              if ($("#bt-" + buildingFrame).hasClass('selected')) {
                $("#bt-" + buildingFrame).removeClass('selected');
                _this.selectedThumb = null;
                $('#baseWidth').val('');
                $('#baseHeight').val('');
                $('#drawWidth').val('');
                $('#drawHeight').val('');
                $('#numberFrames').val('');
                return $('#animationSpeed').val('');
              } else {
                if ($('[id^="bt-"]').hasClass('selected')) {
                  $('[id^="bt-"]').removeClass('selected');
                }
                overlay.removeClass('selected');
                $("#bt-" + buildingFrame).addClass('selected');
                _this.selectedThumb = buildingFrame;
                return _this.displayProperties(buildingFrame);
              }
            });
          })(buildingFrame));
        }
        return _results;
      });
      $('#changeProperties').click(function() {
        return _this.changeProperties();
      });
      return $('#uploadbts').click(function() {
        return _this.uploadBTS();
      });
    };

    UI.prototype.displayProperties = function(buildingThumbName) {
      var buildingNames;
      buildingNames = this.bts_json.name;
      $('#baseWidth').val(buildingNames[buildingThumbName]['tile'].baseW);
      $('#baseHeight').val(buildingNames[buildingThumbName]['tile'].baseH);
      $('#drawWidth').val(buildingNames[buildingThumbName]['tile'].drawW);
      $('#drawHeight').val(buildingNames[buildingThumbName]['tile'].drawH);
      if (buildingNames[buildingThumbName].hasOwnProperty("frames")) {
        $('#numberFrames').val(buildingNames[buildingThumbName]['animation'].frames);
        $('#animationSpeed').val(buildingNames[buildingThumbName]['animation'].speed);
        return $("#animationSpeed").prop('disabled', false);
      } else {
        $('#numberFrames').val('');
        $('#animationSpeed').val('');
        return $("#animationSpeed").prop('disabled', true);
      }
    };

    UI.prototype.changeProperties = function() {
      var JsonObj, buildingNames;
      console.log('Thumb to change is', this.selectedThumb);
      buildingNames = this.bts_json.name;
      if (this.selectedThumb !== null) {
        buildingNames[this.selectedThumb]['tile'].baseW = $('#baseWidth').val();
        buildingNames[this.selectedThumb]['tile'].baseH = $('#baseHeight').val();
        buildingNames[this.selectedThumb]['tile'].drawW = $('#drawWidth').val();
        buildingNames[this.selectedThumb]['tile'].drawH = $('#drawHeight').val();
        if (buildingNames[this.selectedThumb].hasOwnProperty("frames")) {
          buildingNames[this.selectedThumb]['animation'].speed = $('#animationSpeed').val();
        }
      }
      JsonObj = JSON.stringify(this.bts_json, null, 4);
      return console.log(JsonObj);
    };

    UI.prototype.uploadBTS = function() {
      var formData, name, xhr,
        _this = this;
      name = $('#btsName').val();
      formData = new FormData();
      formData.append('bts_jason', this.bts_json);
      formData.append('bts_name', name);
      formData.append('bts_spriteSheet', this.bts_spritesheet_file);
      xhr = new XMLHttpRequest();
      xhr.open('POST', '/uploadBTS', true);
      xhr.onload = function(e) {
        return console.log('yay its done');
      };
      return xhr.send(formData);
      /*
          $.post "/uploadBTS?bts_spriteSheet=#{@bts_spritesheet_url}&bts_jason=#{@bts_json}&bts_name=#{name}", (data) =>
            console.log 'succsess'
      */

    };

    UI.prototype.loadBuildingData = function(flagNumber) {};

    UI.prototype.UIMouseDown = function(e) {
      var idClickEle, x, y;
      x = e.clientX;
      y = e.clientY;
      idClickEle = e.target.getAttribute('id');
      if (idClickEle === 'canvas') {
        if (this.selectedBuilding !== null) {
          game.grid.placeBuilding(x, y, this.selectedBuilding);
        }
      }
      if (idClickEle.indexOf("iconSet") !== -1) {
        if (this.buildingSelectionToolBarVisible === false) {
          this.buildingSelectionToolBarVisible = idClickEle.substring(7, idClickEle.length);
          this.toolSelect = 'build';
          $("#buildingSelectionToolbar").css("visibility", "visible");
          this.loadBuildingData(this.buildingSelectionToolBarVisible);
        } else {
          if (this.buildingSelectionToolBarVisible === idClickEle.substring(7, idClickEle.length)) {
            $("#buildingSelectionToolbar").css("visibility", "hidden");
            $("#buildingSelectionToolbar ul").empty();
            this.buildingSelectionToolBarVisible = false;
            this.toolSelect = null;
          } else {
            this.buildingSelectionToolBarVisible = idClickEle.substring(7, idClickEle.length);
            this.loadBuildingData(this.buildingSelectionToolBarVisible);
          }
        }
      }
      switch (idClickEle) {
        case 'zoomIn':
          this.toolSelect = 'zoomIn';
          this.zoomLevel = this.zoomLevel * 2;
          this.zoomLevel;
          return game.grid.setZoom(this.zoomLevel);
        case 'zoomOut':
          this.toolSelect = 'zoomOut';
          this.zoomLevel = this.zoomLevel / 2;
          return game.grid.setZoom(this.zoomLevel);
      }
    };

    return UI;

  })();

}).call(this);
