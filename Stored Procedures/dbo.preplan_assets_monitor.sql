SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create procedure [dbo].[preplan_assets_monitor]
AS

DECLARE @date_increment smallint, 
	@sysdate DateTime, 
	@asgn_number int,
	@working_asset int, 
	@current_leg int,
	@updated_leg int,
	@first_asgn_num int,
	@reentry_check datetime,
	@current_member int,
	@current_mov	int,
	@first_event	int,
	@last_event	int,
	@first_seq	int,
	@last_seq	int

-- check if in monitor routine already
SELECT 	@reentry_check = gi_date1
FROM	generalinfo
WHERE	gi_name = 'PPAMONITOR'

-- If a monitor SP is already running Exit this one
If IsNull(@reentry_check,'1/1/1970') >= DateAdd(mi,-2,getdate()) RETURN

-- Set the general info setting to prevent running this routine multiple times
If IsNull(@reentry_check,'1/1/1970') = '1/1/1970'
   INSERT INTO generalinfo(gi_name, gi_date1, gi_datein)
   (SELECT 'PPAMONITOR', getdate(), getdate())
ELSE
   UPDATE   generalinfo
   SET      gi_date1 = getdate()
   WHERE    gi_name = 'PPAMONITOR'

-- Initialize variables
SELECT @date_increment = 10
SELECT @working_asset = 0

SELECT 	@date_increment = gi_integer1,
	@sysdate = getdate(),
	@working_asset = 0
FROM	generalinfo
WHERE	gi_name = 'MPNINCREMENT'

WHILE 1=1
BEGIN

  SELECT @working_asset = min(ppa_id)
  FROM preplan_assets p1
  WHERE DATEADD(mi, @date_increment, (select max(ppa_createdon)
					from preplan_assets p2
					where p2.ppa_lgh_number = p1.ppa_lgh_number AND
						p2.ppa_status = 'ACTIVE')) < @sysdate 
	AND ppa_id > @working_asset

  IF ISNULL(@working_asset, 0) <= 0 BREAK

  -- Get the current leg and move number
  SELECT @current_leg = ppa_lgh_number,
	 @current_mov = ppa_mov_number
  FROM	preplan_assets
  WHERE	ppa_id = @working_asset
  
  SELECT @current_member = 0
  SELECT @first_asgn_num = 0

  WHILE 1=1
  BEGIN

	SELECT 	@current_member = min(ppa_id)
	FROM	preplan_assets
	WHERE	ppa_lgh_number = @current_leg AND
		ppa_id > @current_member AND
		ppa_status = 'ACTIVE'


	SELECT 	@first_seq = MIN(stp_mfh_sequence),
		@last_seq = MAX(stp_mfh_sequence)
	FROM	stops
	WHERE	stops.lgh_number = @current_leg

	SELECT 	@first_event = e1.evt_number,
		@last_event = e2.evt_number
	FROM	event e1, event e2, stops s1, stops s2
	WHERE	s1.stp_number = e1.stp_number AND
		s1.lgh_number = @current_leg AND
		s1.stp_mfh_sequence = @first_seq AND		
		s2.stp_number = e2.stp_number AND
		s2.lgh_number = @current_leg AND
		s2.stp_mfh_sequence = @last_seq

	IF ISNULL(@current_member, 0) <=0 BREAK

--mf16830 change asgn_number to identity
--	EXECUTE @asgn_number = getsystemnumber 'ASGNUM', ''
--	moved if to after insert with @@identity
--	IF @first_asgn_num = 0 SELECT @first_asgn_num = @asgn_number

	INSERT INTO assetassignment
	(lgh_number,
--mf16830	asgn_number,  remove
	asgn_type,
	asgn_id,
	asgn_date,
	asgn_eventnumber,
	asgn_controlling,
	asgn_status,
	asgn_dispdate,
	asgn_enddate,
	asgn_dispmethod,
	mov_number,
	pyd_status,
	actg_type,
	evt_number,
	last_evt_number,
	asgn_trl_first_asgn,
	asgn_trl_last_asgn)
	(select ppa_lgh_number,
	--@asgn_number,
	'DRV',
	ppa_driver1,
	ppa_createdon,
	null,
	'N',
	'DNR',
	legheader.lgh_startdate,
	legheader.lgh_enddate,
	null,
	ppa_mov_number,
	'NPD',
	null,
	@first_event,
	@last_event,
	null,
	null
	from preplan_assets, legheader
	where ppa_lgh_number = legheader.lgh_number AND
	ppa_id = @current_member)

	IF @first_asgn_num = 0 SELECT @first_asgn_num = @@identity
	
  END
  -- END LOOP FOR @current_member

  BEGIN TRAN update_preplan_assets 

  UPDATE 	preplan_assets
  SET		ppa_status = 'No Response'
  WHERE 	ppa_lgh_number = @current_leg and
		ppa_status = 'Active'

  UPDATE 	legheader
  SET		lgh_outstatus = 'AVL'
  WHERE 	legheader.lgh_number = @current_leg AND
		@current_leg <> @updated_leg
  SELECT 	@updated_leg = @current_leg

  exec update_move_light @current_mov

  If @@error <> 0
    BEGIN
     ROLLBACK TRAN update_preplan_assets
     DELETE	assetassignment
     WHERE	lgh_number = @current_leg AND
		asgn_number >= @first_asgn_num AND
		asgn_status = 'DNR'
    END
  ELSE
     COMMIT TRAN update_preplan_assets


END
-- END LOOP FOR @current_leg

DELETE   generalinfo
WHERE    gi_name = 'PPAMONITOR'

-- RE - 07/24/01 - PTS #11569
UPDATE	tractorprofile
   SET	trc_status = 'AVL'
  FROM	preplan_assets
 WHERE	trc_status = 'MPN' AND
		trc_number = ppa_tractor AND
		NOT EXISTS (SELECT	*
					  FROM	preplan_assets
					 WHERE	ppa_tractor = trc_number AND
							ppa_status = 'active')

GO
GRANT EXECUTE ON  [dbo].[preplan_assets_monitor] TO [public]
GO
