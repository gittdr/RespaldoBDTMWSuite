SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RptYardCheck]
 @cmp_id varchar(8)
AS
BEGIN
 
 --// reports equipment at a terminal - shows equipment location, status

 CREATE TABLE #yardcheck(
   unit_type   VARCHAR(3),
   unit_id   VARCHAR(13),
   unit_number  VARCHAR(8),
   cmp_id   VARCHAR(8),
   dock_zone   VARCHAR(10),
   move_status  VARCHAR(10),
   work_status  VARCHAR(10),
   door_number  INT,
   status_ts   DATETIME
 );
 
 INSERT INTO #yardcheck(unit_type, unit_id, unit_number, cmp_id, dock_zone, move_status, work_status, door_number, status_ts)

 SELECT unit_type, unit_id, unit_number, cmp_id, dock_zone, move_status, work_status, door_number, status_ts FROM terminal_equipment
 WHERE cmp_id = @cmp_id;
 
 SELECT * from #yardcheck order by dock_zone

RETURN 0
END
GO
GRANT EXECUTE ON  [dbo].[RptYardCheck] TO [public]
GO
