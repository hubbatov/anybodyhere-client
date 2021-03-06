import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import "../Forms/Dialogs" as Dialogs

import "../Controls" as Controls
import "../Controls/FunctionalButtons" as Buttons
import ".." as Global

Rectangle {
	id: __delegate

	property var house: null

	radius: 4
	color: Global.ApplicationStyle.background

	height: __layout.implicitHeight

	signal editRequest(var house)
	signal removeRequest(var house)

	signal addSensorRequest(var house)
	signal editSensorRequest(var house, var sensor)
	signal removeSensorRequest(var house, var sensor)

	signal addCommandRequest(var house)
	signal editCommandRequest(var house, var command)
	signal removeCommandRequest(var house, var command)

	ListModel {
		id: __sensorsModel
	}

	ListModel {
		id: __commandsModel
	}

	LinearGradient {
		id: __footer

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		height: __houseLabel.height

		start: Qt.point(0, 0)
		end: Qt.point(0, __houseLabel.height)
		gradient: Gradient {
			GradientStop { position: 0.0; color: "transparent" }
			GradientStop { position: 0.5; color: Global.ApplicationStyle.frame }
			GradientStop { position: 1.0; color: "transparent" }
		}
	}


	RowLayout{
		anchors.top: __delegate.top; anchors.topMargin: 5
		anchors.right: __delegate.right; anchors.rightMargin: 5

		Buttons.AddButton{
			iconSize: Global.ApplicationStyle.iconSize
			color: Global.ApplicationStyle.contrast

			onClicked: {
				addCommandRequest(house)
			}
		}

		Buttons.AddButton{
			iconSize: Global.ApplicationStyle.iconSize
			color: Global.ApplicationStyle.contrast

			onClicked: {
				addSensorRequest(house)
			}
		}

		Buttons.EditButton {
			onClicked: {
				editRequest(house)
			}
		}

		Buttons.RemoveButton {
			onClicked: {
				removeRequest(house)
			}
		}
	}

	ColumnLayout {
		id: __layout

		spacing: 10

		anchors.top: __delegate.top; anchors.topMargin: 10
		anchors.left: __delegate.left; anchors.leftMargin: 10
		anchors.right: __delegate.right; anchors.rightMargin: 10

		Controls.LabelBold {
			id: __houseLabel
			text: !!house ? house.name : ""
		}

		Controls.LabelRegular {
			id: __houseDescriptionLabel
			font: Global.ApplicationStyle.smallFont
			text: !!house ? house.address : ""
		}

		Controls.LabelItalic {
			id: __houseNoSensorsLabel
			text: qsTr("No sensors available")
			visible: __sensorsModel.count === 0 && __commandsView.count
		}

		Repeater {
			id: __commandsView

			model: __commandsModel.count

			delegate: CommandDelegate{
				implicitHeight: height

				Layout.fillWidth: true

				house: __delegate.house
				command: __commandsModel.get(index)

				onEditRequest: {
					editCommandRequest(house, command)
				}

				onRemoveRequest: {
					removeCommandRequest(house, command)
				}

				Component.onCompleted: {
					updateControls()
				}
			}
		}

		Repeater {
			id: __sensorsView

			model: __sensorsModel.count

			delegate: SensorDelegate{
				implicitHeight: height

				Layout.fillWidth: true

				house: __delegate.house
				sensor: __sensorsModel.get(index)

				onEditRequest: {
					editSensorRequest(house, sensor)
				}

				onRemoveRequest: {
					removeSensorRequest(house, sensor)
				}
			}
		}
	}

	function updateCommandsModel(){
		__sensorsModel.clear()

		if(!house) return

		var sensorsRequestString = "users/" + Global.Application.restProvider.currentUserId()
		sensorsRequestString += "/houses/" + house.id
		sensorsRequestString += "/commands"
		Global.Application.restProvider.list(sensorsRequestString, undefined, fillCommandsModel)
	}

	function fillCommandsModel(response){
		if("answer" in response){
			var commands = JSON.parse(response.answer)
			if(commands.length){
				commands.forEach(function(command, i, commands){
					__commandsModel.append(command)
				})
			}
		}
	}

	function updateSensorsModel(){
		__sensorsModel.clear()

		if(!house) return

		var sensorsRequestString = "users/" + Global.Application.restProvider.currentUserId()
		sensorsRequestString += "/houses/" + house.id
		sensorsRequestString += "/sensors"
		Global.Application.restProvider.list(sensorsRequestString, undefined, fillSensorsModel)
	}

	function fillSensorsModel(response){
		if("answer" in response){
			var sensors = JSON.parse(response.answer)
			if(sensors.length){
				sensors.forEach(function(sensor, i, sensors){
					__sensorsModel.append(sensor)
				})
			}
		}
	}
}
