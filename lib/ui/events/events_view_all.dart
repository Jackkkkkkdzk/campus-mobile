import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/providers/events.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
// import 'package:campus_mobile_experimental/ui/common/event_time.dart';
// import 'package:campus_mobile_experimental/ui/common/image_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EventsAll extends StatelessWidget {
  const EventsAll({Key? key, this.listSize}) : super(key: key);

  final int? listSize;

  @override
  Widget build(BuildContext context) {
    return Provider.of<EventsDataProvider>(context).isLoading!
        ? Center(
        child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary))
        : buildEventsList(
        Provider.of<EventsDataProvider>(context).eventsModels!, context);
  }

  Widget buildEventsList(List<EventModel> listOfEvents, BuildContext context) {
    final List<Widget> eventTiles = [];
    final screenSize = MediaQuery.of(context).size;
    double height = screenSize.height;
    double width = screenSize.width;

    /// check to see if we want to display only a limited number of elements
    /// if no constraint is given on the size of the list then all elements
    /// are rendered
    // var size = listSize;
    // if (listSize == null) {
    //   size = 3;
    //   height /= 2;
    //   width /= 1.4;
    // } else
    //   size = listSize;

    /// check to see if we have at least 3 events
    // if (size > listOfEvents.length) {
    //   size = listOfEvents.length;
    // }

    for (int i = 0; i < listOfEvents.length; i++) {
      final EventModel item = listOfEvents[i];
      final tile = buildEventTile(item, context, height, width);
      eventTiles.add(tile);
    }

    if (listSize != null) {
      return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: eventTiles,
        ),
      );
    } else {
      print("in else block");
      return ContainerView(
        child: listOfEvents.isEmpty
            ? Center(child: Text('No events found.'))
            : Container(
              color: Colors.green,
                  child: GridView.count(
                    mainAxisSpacing: 200,
                    crossAxisCount: 2,
                    // crossAxisSpacing: 40,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: eventTiles,
                  ),
                ),
      );
    }
    // ListView(
    //   children:
    //   ListTile.divideTiles(tiles: eventTiles, context: context)
    //       .toList(),
  }

  Widget buildEventTile(
      EventModel data, BuildContext context, double height, double width) {
    double padding = height * 0.03;
    double sizedBoxHeight = height * 0.01;
    double imageHeight = height / 8;
    double cardWidth = width / 1.6;
    double minTextConHeight = width * 0.15;
    return Container(
      color: Colors.pink,
      height: imageHeight + minTextConHeight,
      width: cardWidth,
      child: Column(
        children: [
            Padding( padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Container(
              width: cardWidth,
              height: imageHeight,
              decoration: BoxDecoration(
                  color: Colors.red,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(data.imageThumb!),
                  )
              ),

            ),
          ),
        // Padding(padding: EdgeInsets.only(top: 100)),
        Padding(
          padding: const EdgeInsets.only(right: 20, bottom: 20, left: 20),
          child: Container(
            child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, RoutePaths.EventDetailView,
                      arguments: data);
                },
                child: Container(
                  width: cardWidth,
                  padding:
                  EdgeInsets.fromLTRB(padding, 0, padding, sizedBoxHeight),
                  decoration: BoxDecoration(
                      color: Colors.purple,
                      border: Border.all(width: 0.3),
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.expand_less),
                        color: Colors.grey,
                        onPressed: () {
                          Navigator.pushNamed(context, RoutePaths.EventDetailView,
                              arguments: data);
                        },
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(minHeight: minTextConHeight),
                        child: Text(
                          data.title!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: lightButtonColor,
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: sizedBoxHeight,
                      ),
                      EventsDateTime(data),
                    ],
                  ),
                ),
              ),
          ),
        ),
        ],
      ),
    );
  }

  Widget eventImageLoader(String? url, double height) {
    return url!.isEmpty
        ? Container(
      width: 0,
      height: 0,
    )
        : Image.network(
      url,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      fit: BoxFit.fill,
      height: height / 5,
    );
  }

  Widget EventsDateTime(EventModel data) {
    try {
      // Separate dates from times
      String startMonthDayYear =
      DateFormat.yMMMMd('en_US').format(data.startDate!.toLocal());
      String endMonthDayYear =
      DateFormat.yMMMMd('en_US').format(data.endDate!.toLocal());
      String startTime = DateFormat.jm().format(data.startDate!.toLocal());
      String endTime = DateFormat.jm().format(data.endDate!.toLocal());

      // Mark any special types of events
      bool sameDay = (startMonthDayYear == endMonthDayYear);
      bool unspecifiedTime = (startTime == '12:00 AM' && endTime == '12:00 AM');
      Widget date;
      Widget time;
      if (sameDay) {
        date = Text(startMonthDayYear); // Ex. June 11, 2021
      } else {
        // if not the same date, check if the same year
        String startYear = startMonthDayYear.substring(
            startMonthDayYear.indexOf(',') + 2, startMonthDayYear.length);
        String endYear = endMonthDayYear.substring(
            endMonthDayYear.indexOf(',') + 2, endMonthDayYear.length);
        if (startYear == endYear) {
          // if the same year, check if the same month
          String startMonth =
          startMonthDayYear.substring(0, startMonthDayYear.indexOf(' '));
          String endMonth =
          endMonthDayYear.substring(0, endMonthDayYear.indexOf(' '));
          if (startMonth == endMonth) {
            // if different date in the same month and year
            String startDay = startMonthDayYear.substring(
                startMonthDayYear.indexOf(' ') + 1,
                startMonthDayYear.indexOf(','));
            String endDay = endMonthDayYear.substring(
                endMonthDayYear.indexOf(' ') + 1, endMonthDayYear.indexOf(','));
            date = Text(startMonth +
                ' ' +
                startDay +
                ' - ' +
                endDay +
                ', ' +
                startYear); // Ex. September 11 - 26, 2021
          } else {
            // if different month in the same year
            String startMonthDay =
            startMonthDayYear.substring(0, startMonthDayYear.indexOf(','));
            String endMonthDay =
            endMonthDayYear.substring(0, endMonthDayYear.indexOf(','));
            date = Text(
              startMonthDay + ' - ' + endMonthDay + ', ' + startYear,
            ); // Ex. September 11 - October 26, 2021
          }
        } else {
          date = Text(
            startMonthDayYear + ' - ' + endMonthDayYear,
          ); // Ex. June 11, 2021 - May 12, 2023
        }
      }

      if (unspecifiedTime) {
        time = Text('');
      } else {
        time = Text(
          startTime + ' - ' + endTime,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [date, time],
      );
    } catch (e) {
      print(e);
      return Container();
    }
  }
}