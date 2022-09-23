SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  Stored Procedure dbo.instatus    Script Date: 8/20/97 1:59:16 PM ******/
CREATE PROCEDURE [dbo].[instatus] @trc CHAR(8)
---declare @trc CHAR(8) = '1307'
AS
/*
 09/14/2006, PTS34496, rewrite the 1st "Update legheader" statement using loop to avoid multiple row update.
 12/05/2006, PTS35375, rewrite and split the select statement for "INSERT INTO @lgh_hstn" to improve performance
 09/05/2007, PTS39036, add index hint "with (index(dk_tractor_active))" to "INSERT INTO @lgh"
 07/07/2011, PTS57794 MTC Add nolocks on all core table selects, remove above index hint
 11/24/2014, PTS84843 MTC Overhaul to minimize updates to legheader table.
 12/17/2014, PTS84843 MTC Make sure that records going into table for update are unique
*/
SET NOCOUNT ON

--DECLARE @trc CHAR(8)
--SELECT @trc = 'C624'

DECLARE @lastlgh   INT,
        @opn       INT,
        @instat    CHAR(3),
        @active    CHAR(1),
        @lastplannedlgh INT,
        @advtrcplanning CHAR(1)

IF @trc <> 'UNKNOWN'
BEGIN
 	SET NOCOUNT ON

    SELECT @advtrcplanning = ISNULL(UPPER(left(gi_string1,1)), 'N') -- RE - 5/17/04 - PTS #23089
       FROM     generalinfo with (nolock)
       WHERE    gi_name = 'ADVTRCPLANNING'

    --get @lastlgh
    EXECUTE cur_activity 'TRC', @trc, @lastlgh OUT

    SELECT @active = 'N'

    IF EXISTS(SELECT stops.stp_number
     FROM [event] with (nolock), stops with (nolock), carrier with (nolock)
     WHERE event.stp_number = stops.stp_number AND
       lgh_number = @lastlgh AND
       evt_carrier = car_id AND
       car_board = 'N' AND
    car_id <> 'UNKNOWN')
    	-- RE - 11/19/02 - PTS #16261 End
    	SELECT @instat = 'HST'
    ELSE
    BEGIN
    	SELECT @opn = COUNT(*)
    	   FROM assetassignment with (nolock)
	    	-- JET - PTS #5345 - 3/22/99, include dispatch status in determining next status
    		--            WHERE assetassignment.asgn_status = 'PLN' AND
    	   WHERE asgn_status IN ('PLN', 'DSP') AND
        asgn_type = 'TRC' AND
        asgn_id = @trc
	     IF @opn > 0
	        SELECT @instat = 'PLN'
	     ELSE
	        SELECT @instat = 'UNP'
	     SELECT @active = 'Y'
     END

	--get @lastplannedlgh
    SELECT @lastplannedlgh = max(lgh_number)
    FROM assetassignment with (nolock)
    WHERE asgn_type = 'TRC' AND
    asgn_id = @trc AND
    asgn_date = (
      SELECT max(asgn_date)
      FROM assetassignment with (nolock)
      WHERE asgn_type = 'TRC' AND
      asgn_id = @trc
      )
    
    DECLARE @lgh_number INT, @lgh_instatus varchar (6), @lgh_active char(1)

    DECLARE @lgh_to_update TABLE (
     lgh_number INT PRIMARY KEY,
     lgh_instatus varchar(6),
     lgh_active CHAR(1))

    --select @lastlgh
    --select @lastplannedlgh

    --insert values to update for for @lastlgh
    insert into @lgh_to_update (lgh_number, lgh_instatus, lgh_active)
    select lgh_number, @instat, @active from legheader where lgh_number = @lastlgh AND
    (
    isnull(lgh_instatus,'X') <> @instat OR
    isnull(lgh_active,'X') <> @active
    )

    --insert values to update for @lastplannedlgh
    insert into @lgh_to_update (lgh_number, lgh_instatus, lgh_active)
    select l.lgh_number, 'UNP', 'Y'
    from legheader l where
    l.lgh_number = @lastplannedlgh AND
    l.lgh_tractor = @trc AND
    l.lgh_active = 'Y' AND
    ISNULL(l.lgh_instatus, 'X') <> 'UNP'  AND
                NOT EXISTS (select lgh_number from @lgh_to_update where lgh_number = l.lgh_number)

    --Get CMP legs for this tractor that are not set to HIST or active = N
    insert into @lgh_to_update (lgh_number, lgh_instatus, lgh_active)
    SELECT l.lgh_number, 'HST','N'
    FROM legheader l with (nolock)
    WHERE l.lgh_tractor = @trc AND
    l.lgh_outstatus = 'CMP' AND
    (l.lgh_instatus is null or l.lgh_instatus <> 'HST') AND -- RE - 5/17/04 - PTS #23089
    l.lgh_number <> @lastlgh AND
                NOT EXISTS (select lgh_number from @lgh_to_update where lgh_number = l.lgh_number)
    UNION
    SELECT l.lgh_number, 'HST','N'
    FROM legheader l with (nolock)
    WHERE l.lgh_tractor = @trc AND
    l.lgh_outstatus = 'CMP' AND
    (l.lgh_active is null or l.lgh_active <> 'N') AND -- RE - 5/17/04 - PTS #23089
    l.lgh_number <> @lastlgh AND
                NOT EXISTS (select lgh_number from @lgh_to_update where lgh_number = l.lgh_number)
    order by lgh_number
    
    IF @advtrcplanning = 'N'
    BEGIN
              insert into @lgh_to_update (lgh_number, lgh_instatus, lgh_active)
              select l.lgh_number, @instat, 'Y'
              from legheader l where l.lgh_active = 'Y' and l.lgh_tractor = @trc AND
              ISNULL(l.lgh_instatus, 'X') <> @instat AND
              l.lgh_number <> @lastplannedlgh AND
              l.lgh_number <> @lastlgh AND
                                  NOT EXISTS (select lgh_number from @lgh_to_update where lgh_number = l.lgh_number)
       END

       IF @advtrcplanning = 'Y'
       BEGIN
        DECLARE @ADVTRCPLANNING_VALUES TABLE (
	       lgh_number INT PRIMARY KEY,
	       lgh_outstatus varchar(6),
	       lgh_active CHAR(1));

           WITH
	       ACTIVE_LH_FOR_A_TRC (lgh_number, lgh_enddate, lgh_outstatus) AS
	              (
	              SELECT lgh_number, lgh_enddate, lgh_outstatus
	              FROM legheader WHERE lgh_active = 'Y' and lgh_tractor= @trc
	              )
			  INSERT INTO @ADVTRCPLANNING_VALUES
					select lgh_number, (SELECT TOP 1 lgh_outstatus FROM legheader WHERE lgh_tractor = @trc and lgh_enddate = (SELECT MIN(x.lgh_enddate) FROM legheader x WHERE x.lgh_tractor = @trc and x.lgh_enddate > ACTIVE_LH_FOR_A_TRC.lgh_enddate)) outstatus, 'Y' 
					from ACTIVE_LH_FOR_A_TRC  ;

	          update @lgh_to_update 
	          set lgh_instatus = a.lgh_outstatus, lgh_active = 'Y'
	          from @lgh_to_update l inner join @ADVTRCPLANNING_VALUES a on l.lgh_number = a.lgh_number
			  where l.lgh_number <> @lastplannedlgh 

	          insert into @lgh_to_update (lgh_number, lgh_instatus, lgh_active)
	          select a.lgh_number, a.lgh_outstatus, a.lgh_active
	          from @ADVTRCPLANNING_VALUES a
	          where not exists (Select * from @lgh_to_update u where u.lgh_number = a.lgh_number);
	          update @lgh_to_update set lgh_instatus = 'UNP' where lgh_instatus = 'AVL' or lgh_instatus is null
			  ---select l.lgh_outstatus, l.lgh_instatus, * from @lgh_to_update ll join legheader l on ll.lgh_number = l.lgh_number 
       END

    --Now, must go into a loop because update triggers on LH have single row logic
    DECLARE LEGS_TO_FIX CURSOR FAST_FORWARD FOR
	    select l2u.lgh_number, l2u.lgh_instatus, l2u.lgh_active
        from @lgh_to_update l2u INNER JOIN legheader l ON l2u.lgh_number = l.lgh_number
           WHERE (l.lgh_instatus <> l2u.lgh_instatus or l.lgh_active <>l2u.lgh_active) AND l.lgh_tractor = @trc
		order by l.lgh_number

    OPEN LEGS_TO_FIX
    FETCH NEXT FROM LEGS_TO_FIX INTO @lgh_number, @lgh_instatus, @lgh_active

    WHILE @@FETCH_STATUS = 0

    BEGIN
	    update legheader set lgh_instatus = @lgh_instatus, lgh_active = @lgh_active
	    where lgh_number = @lgh_number and lgh_tractor = @trc

	    FETCH NEXT FROM LEGS_TO_FIX INTO @lgh_number, @lgh_instatus, @lgh_active
    END

    CLOSE LEGS_TO_FIX
    DEALLOCATE LEGS_TO_FIX

END
GO
GRANT EXECUTE ON  [dbo].[instatus] TO [public]
GO
