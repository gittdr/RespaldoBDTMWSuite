SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Old ID, is the employee to which the information will be merged (assuming the ID was entered into the system before the SAP/HR import)
-- New ID, is the employee record from which official information will come from (record with SAP ID stored on it)
CREATE PROCEDURE [dbo].[ReplaceDriverInSystem] 
	@OldAsgn_id VARCHAR(8),
	@NewAsgn_id VARCHAR(8)
AS
-- return states
--	-1 could not find the Old or New ID in the manpowerprofile table
--	-2 the branch for settling the employee is marked as RTC or Closed for the current period
--	-3 a settlement exists for the employee
--	-4 the branch billto for billing an order/trip for the employee is marked as RTC or Closed for the current period
--  -5 a bill exists for an order/trip for the employee
--  -6 a trip assignment still exists for the employee
--	-7 a master file still has a reference to the employee

--DECLARE @new_mpp_otherid	VARCHAR(25),
--	@new_mpp_branch		VARCHAR(12),
--	@new_mpp_type2		VARCHAR(6),
--	@new_mpp_type3		VARCHAR(6)
DECLARE @returnValue INT

--Check to see if they are valid records before continuing.
IF (SELECT COUNT(*) FROM manpowerprofile WHERE mpp_id = @OldAsgn_id) = 0
BEGIN
	INSERT INTO DriverReplaceLog (drl_existingid, drl_newid, drl_user, drl_date, drl_tripschanged, drl_comment)
						  VALUES (@OldAsgn_id, @NewAsgn_id, USER_NAME(), GETDATE(), 0, 'EXIST ERROR')
	set @returnValue = -1
	GOTO ExitProc
END
IF (SELECT COUNT(*) FROM manpowerprofile WHERE mpp_id = @NewAsgn_id) = 0
BEGIN
	INSERT INTO DriverReplaceLog (drl_existingid, drl_newid, drl_user, drl_date, drl_tripschanged, drl_comment)
						  VALUES (@OldAsgn_id, @NewAsgn_id, USER_NAME(), GETDATE(), 0, 'EXIST ERROR')
	set @returnValue = -1
	GOTO ExitProc
END

-- make sure branch is not in Close/Ready To Close state
if ISNULL((SELECT brn_readytoclose FROM branch join manpowerprofile ON brn_id = mpp_branch AND mpp_id = @OldAsgn_id AND brn_readytoclose = 'Y'), 'N') = 'Y'
BEGIN
	INSERT INTO DriverReplaceLog (drl_existingid, drl_newid, drl_user, drl_date, drl_tripschanged, drl_comment)
						  VALUES (@OldAsgn_id, @NewAsgn_id, USER_NAME(), GETDATE(), 0, 'BRN ERROR')
	set @returnValue = -2
	GOTO ExitProc
END
if ISNULL((SELECT brn_readytoclose FROm branch JOIN manpowerprofile ON brn_id = mpp_branch AND mpp_id = @NewAsgn_id AND brn_readytoclose = 'Y'), 'N') = 'Y'
BEGIN
	INSERT INTO DriverReplaceLog (drl_existingid, drl_newid, drl_user, drl_date, drl_tripschanged, drl_comment)
						  VALUES (@OldAsgn_id, @NewAsgn_id, USER_NAME(), GETDATE(), 0, 'BRN ERROR')
	set @returnValue = -2
	GOTO ExitProc
END

--check for settled and billed orders/trips before making any other changes
BEGIN TRANSACTION SettlementUpdate
	-- make sure branch is set to recompute pay
	UPDATE branch 
	   SET brn_payroll_fullgeneration_complete = 'N'
	 WHERE brn_id = (select mpp_branch from manpowerprofile where mpp_id = @OldAsgn_id) 
	   AND brn_payroll_fullgeneration_complete = 'Y' 
	UPDATE branch 
	   SET brn_payroll_fullgeneration_complete = 'N'
	 WHERE brn_id = (select mpp_branch from manpowerprofile where mpp_id =  @NewAsgn_id) 
	   AND brn_payroll_fullgeneration_complete = 'Y' 
	 
	-- uncouple pay details from headers in COL and HLD state
	UPDATE paydetail 
	   SET pyh_payperiod = '20491231 23:59:59', 
	       pyh_number = 0 
	 WHERE pyh_number in (SELECT pyh_pyhnumber FROM payheader WHERE asgn_type = 'DRV' AND asgn_id in (@OldAsgn_id, @NewAsgn_id) AND pyh_paystatus in ('HLD', 'COL'))
	-- remove pay headers in the COL and HLD state (closed and transferred need handled differently)
	DELETE FROM payheader WHERE asgn_type = 'DRV' AND asgn_id in (@OldAsgn_id, @NewAsgn_id) AND pyh_paystatus in ('HLD', 'COL') AND NOT EXISTS(SELECT pyd_number FROM paydetail WHERE pyh_number = pyh_pyhnumber)
	-- delete auto rated details for @NewAsgn_id
	DELETE FROM paydetail WHERE asgn_type = 'DRV' AND asgn_id = @NewAsgn_id AND pyd_updsrc IN ('A', 'P')
	-- update manual adjustments for @NewAsgn_id
	UPDATE paydetail 
	   SET asgn_id = @OldAsgn_id 
	 WHERE asgn_type = 'DRV' 
	   AND asgn_id = @NewAsgn_id 
	   AND pyh_number = 0

--Make sure there are no remaining pay headers for @NewAsgn_id
IF (SELECT COUNT(*) FROM payheader WHERE asgn_type = 'DRV' AND asgn_id = @NewAsgn_id) > 0 
BEGIN
	ROLLBACK TRANSACTION SettlementUpdate
	INSERT INTO DriverReplaceLog (drl_existingid, drl_newid, drl_user, drl_date, drl_tripschanged, drl_comment)
						  VALUES (@OldAsgn_id, @NewAsgn_id, USER_NAME(), GETDATE(), 0, 'STL ERROR')
	set @returnValue = -3
	GOTO ExitProc
END
ELSE
BEGIN
	COMMIT TRANSACTION SettlementUpdate
END

-- make sure branch_billto is not in Close/Ready To Close state
if ISNULL((SELECT DISTINCT(bbc_readytoclose) FROM branch_billtos join manpowerprofile ON bbc_brn_id = mpp_branch AND mpp_id = @OldAsgn_id And bbc_readytoclose = 'Y'), 'N') = 'Y'
BEGIN
	INSERT INTO DriverReplaceLog (drl_existingid, drl_newid, drl_user, drl_date, drl_tripschanged, drl_comment)
						  VALUES (@OldAsgn_id, @NewAsgn_id, USER_NAME(), GETDATE(), 0, 'BBC ERROR')
	set @returnValue = -4
	GOTO ExitProc
END 
if ISNULL((SELECT DISTINCT(bbc_readytoclose) FROM branch_billtos JOIN manpowerprofile ON bbc_brn_id = mpp_branch AND mpp_id = @NewAsgn_id And bbc_readytoclose = 'Y'), 'N') = 'Y'
BEGIN
	INSERT INTO DriverReplaceLog (drl_existingid, drl_newid, drl_user, drl_date, drl_tripschanged, drl_comment)
						  VALUES (@OldAsgn_id, @NewAsgn_id, USER_NAME(), GETDATE(), 0, 'BBC ERROR')
	set @returnValue = -4
	GOTO ExitProc
END 

BEGIN TRANSACTION BillingUpdate
	--Update branch bill to records so the branch bill to will be full generated again (driver change may cause a difference in rates)
	UPDATE branch_billtos 
	   SET bbc_fullgeneration_complete = 'N'
	 WHERE bbc_brn_id = (select mpp_branch from manpowerprofile where mpp_id = @OldAsgn_id) 
	   AND bbc_fullgeneration_complete = 'Y' 
	UPDATE branch_billtos 
	   SET bbc_fullgeneration_complete = 'N'
	 WHERE bbc_brn_id = (select mpp_branch from manpowerprofile where mpp_id = @NewAsgn_id) 
	   AND bbc_fullgeneration_complete = 'Y' 

	--Update any invoice headers.
	UPDATE invoiceheader 
	   SET ivh_driver = @OldAsgn_id 
	 WHERE ivh_driver = @NewAsgn_id 
	   AND ivh_invoicestatus <> 'XFR' 
	   AND ivh_mbstatus <> 'XFR' 
	UPDATE invoiceheader 
	   SET ivh_driver2 = @OldAsgn_id 
	 WHERE ivh_driver2 = @NewAsgn_id 
	   AND ivh_invoicestatus <> 'XFR' 
	   AND ivh_mbstatus <> 'XFR' 
	   
--make sure there are no remaining invoice headers for @NewAsgn_id
IF (SELECT COUNT(*) FROM invoiceheader WHERE ivh_driver = @NewAsgn_id OR ivh_driver2 = @NewAsgn_id) > 0
BEGIN
	ROLLBACK TRANSACTION BillingUpdate
	INSERT INTO DriverReplaceLog (drl_existingid, drl_newid, drl_user, drl_date, drl_tripschanged, drl_comment)
						  VALUES (@OldAsgn_id, @NewAsgn_id, USER_NAME(), GETDATE(), 0, 'BILL ERROR')
	set @returnValue = -5
	GOTO ExitProc
END
ELSE
BEGIN
	COMMIT TRANSACTION BillingUpdate
END

-- merge in an update statement instead of selecting to a variable
--SELECT @new_mpp_otherid = mpp_otherid, 
--       @new_mpp_branch = mpp_branch, 
--       @new_mpp_type2 = ISNULL(mpp_type2, 'UNK'), 
--       @new_mpp_type3 = ISNULL(mpp_type3, 'UNK')
--  FROM manpowerprofile
-- WHERE mpp_id = @newasgn_id
--
--UPDATE manpowerprofile
--   SET mpp_otherid = @new_mpp_otherid,
--       mpp_branch = @new_mpp_branch,
--       mpp_type2 = @new_mpp_type2,
--       mpp_type3 = @new_mpp_type3
-- WHERE mpp_id = @oldasgn_id
 
--Find records to change and calculate a count for later comparison.
DECLARE @RecordsToChange INT, @NewRecordCount INT
SELECT @RecordsToChange = count(*) FROM assetassignment WHERE asgn_type = 'DRV' AND asgn_id = @NewAsgn_id
SELECT @NewRecordCount = count(*) FROM assetassignment WHERE asgn_type = 'DRV' AND asgn_id = @OldAsgn_id
SELECT lgh_number, mov_number INTO #tempAsgnRecords FROM assetassignment WHERE asgn_type = 'DRV' AND asgn_id = @NewAsgn_id

BEGIN TRANSACTION TripUpdate
	--Loop through all assignment records for existing driver.
	WHILE (SELECT COUNT(*) FROM #tempAsgnRecords) > 0 
	BEGIN
		DECLARE @currentLeg INT
		DECLARE @currentMove INT
		
		--Select the first record for processing and load all stops for that leg.
		SELECT TOP 1 @currentLeg = lgh_number, @currentMove = mov_number FROM #tempAsgnRecords 
		SELECT stp_number INTO #tempStopRecDel FROM stops WHERE lgh_number = @currentLeg
		
		--Loop through all stops to find their events for update.
		WHILE (SELECT COUNT(*) FROM #tempStopRecDel) > 0
		BEGIN
			DECLARE @currentStop INT
			
			--Select the first record for processing.
			SELECT TOP 1 @currentStop = stp_number FROM #tempStopRecDel ORDER BY stp_number
			
			--Update driver1 and driver2 to the new values.
			UPDATE [event] SET evt_driver1 = @OldAsgn_id WHERE evt_driver1 = @NewAsgn_id AND stp_number = @currentStop
			UPDATE [event] SET evt_driver2 = @OldAsgn_id WHERE evt_driver2 = @NewAsgn_id AND stp_number = @currentStop
			
			--Remove the record that was currently process from the temp table.
			DELETE FROM #tempStopRecDel WHERE stp_number = @currentStop
		END

		--Clean up stops temp table.
		DROP TABLE #tempStopRecDel	
		
		--Call Update_move for the move that was just processed.
		EXEC update_move @currentmove
		
		--Remove the assetassignment record that was just processed.
		DELETE FROM #tempAsgnRecords WHERE lgh_number = @currentLeg
	END

	--Clean up the assetassignment temp table.
	DROP TABLE #tempAsgnRecords 

--Check to see if the record counts from the old id compares to the new id in the assetassignment table.
--If not, rollback.
IF (SELECT count(*) FROM assetassignment WHERE asgn_type = 'DRV' AND asgn_id = @OldAsgn_id) = (@RecordsToChange + @NewRecordCount)
BEGIN
	COMMIT TRANSACTION TripUpdate
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TripUpdate
	INSERT INTO DriverReplaceLog (drl_existingID, drl_newID, drl_user, drl_date, drl_tripsChanged, drl_comment)
		VALUES(@OldAsgn_id, @NewAsgn_id, USER_NAME(),GETDATE(), @RecordsToChange, 'TRP ERROR')
	set @returnValue = -6
	GOTO ExitProc
END

BEGIN TRANSACTION MasterFileUpdate
	--Update tractorprofile
	UPDATE tractorprofile 
	   SET trc_driver = @OldAsgn_id
	 WHERE trc_driver = @NewAsgn_id

	--Update any expiration records
	UPDATE expiration 
	   SET exp_id = @OldAsgn_id
	 WHERE exp_id = @NewAsgn_id 
	   AND exp_idtype = 'DRV'

	--Update any notes records
	UPDATE notes 
	   SET nre_tablekey = @OldAsgn_id 
	 WHERE nre_tablekey = @NewAsgn_id
	   AND ntb_table = 'manpowerprofile'

	--Update any driver images
	UPDATE imagedriverlist 
	   SET mpp_id = @OldAsgn_id
     WHERE mpp_id = @NewAsgn_id
     
	--Update any driver blob images
	UPDATE ps_blob_data 
	   SET blob_key = @OldAsgn_id
     WHERE blob_table = 'manpowerprofile' 
       AND blob_key = @NewAsgn_id
     
	--Update any driver qualifications
	UPDATE driveraccident 
	   SET mpp_id = @OldAsgn_id
     WHERE mpp_id = @NewAsgn_id

	--Update any driver qualifications
	UPDATE driverqualifications 
	   SET drq_driver = @OldAsgn_id
     WHERE drq_driver = @NewAsgn_id

	--Update any driver testing
	UPDATE drivertesting 
	   SET mpp_id = @OldAsgn_id
     WHERE mpp_id = @NewAsgn_id

	--Update any driver training
	UPDATE drivertraining 
	   SET mpp_id = @OldAsgn_id
     WHERE mpp_id = @NewAsgn_id

	--Update any driver complaints
	UPDATE drivercomplaint 
	   SET mpp_id = @OldAsgn_id
     WHERE mpp_id = @NewAsgn_id

	--Update any driver log violations
	UPDATE driverlogviolation 
	   SET mpp_id = @OldAsgn_id
     WHERE mpp_id = @NewAsgn_id
     
	--Update any contact profiles
	UPDATE contact_profile 
	   SET con_id = @OldAsgn_id
     WHERE con_id = @NewAsgn_id 
       AND con_asgn_type = 'DRIVER'
       
	--Update any driver documents
	UPDATE driverdocument 
	   SET mpp_id = @OldAsgn_id
     WHERE mpp_id = @NewAsgn_id 
       AND drd_type = 'D'
       
	--Update any driver check calls
	UPDATE checkcall 
	   SET ckc_asgnid = @OldAsgn_id
	 WHERE ckc_asgntype = 'DRV'
       AND ckc_asgnid = @NewAsgn_id

	--Update any driver logs
	UPDATE log_driverlogs 
	   SET mpp_id = @OldAsgn_id
     WHERE mpp_id = @NewAsgn_id

	--Update any driver violations
	UPDATE log_driverviolations 
	   SET mpp_id = @OldAsgn_id
     WHERE mpp_id = @NewAsgn_id

	--Update any missing logs
	UPDATE log_missinglogs 
	   SET mpp_id = @OldAsgn_id
     WHERE mpp_id = @NewAsgn_id

	--Update any home logs
	UPDATE manpowerhomelog 
	   SET mpp_id = @OldAsgn_id
     WHERE mpp_id = @NewAsgn_id

	-- update schedule table
	UPDATE schedule_table 
	   SET mpp_id = @OldAsgn_id
	 WHERE mpp_id = @NewAsgn_id
	
	-- update driver calendar
	UPDATE drivercalendar 
	   SET mpp_id = @OldAsgn_id
	 WHERE mpp_id = @NewAsgn_id

	-- update driver calendar history
	UPDATE drivercalendarhistory 
	   SET mpp_id = @OldAsgn_id
	 WHERE mpp_id = @NewAsgn_id
	 
	-- store @NewAsgn_id other ID, and update the field on @NewAsgn_id to protect unique index on mpp_otherid
	SELECT mpp_otherid, 
	       mpp_company, 
		   mpp_branch, 
 		   mpp_lastname, 
 		   mpp_firstname, 
 		   mpp_middlename, 
		   mpp_type1, 
		   mpp_type2, 
		   mpp_type3, 
		   mpp_type4, 
		   mpp_hiredate, 
 		   mpp_senioritydate, 
 		   mpp_terminationdt, 
 		   mpp_address1, 
 		   mpp_address2, 
 		   mpp_city, 
 		   mpp_zip, 
		   mpp_misc1, 
		   mpp_misc2, 
		   mpp_misc3, 
		   mpp_misc4, 
		   mpp_currentphone, 
		   mpp_homephone, 
		   mpp_emername, 
		   mpp_emerphone, 
		   mpp_licensenumber, 
		   mpp_licenseclass, 
		   mpp_licensestate, 
 		   mpp_employeetype, 
 		   mpp_ssn 
	  INTO #temp 
	  FROM manpowerprofile 
	 WHERE mpp_id = @NewAsgn_id
	UPDATE manpowerprofile 
	   SET mpp_otherid = NULL 
	 WHERE mpp_id = @NewAsgn_id
	  
	--jet - 3/7/12 - PTS 61664, make sure all fields that were loaded in the new ID are replaced in the old ID
	UPDATE manpowerprofile 
	   SET mpp_otherid = mp2.mpp_otherid, 
	       mpp_company = mp2.mpp_company, 
		   mpp_branch = mp2.mpp_branch, 
 		   mpp_lastname = mp2.mpp_lastname, 
 		   mpp_firstname = mp2.mpp_firstname, 
 		   mpp_middlename = mp2.mpp_middlename, 
		   mpp_type1 = mp2.mpp_type1, 
		   mpp_type2 = mp2.mpp_type2, 
		   mpp_type3 = mp2.mpp_type3, 
		   mpp_type4 = mp2.mpp_type4, 
		   mpp_hiredate = mp2.mpp_hiredate,
 		   mpp_senioritydate = mp2.mpp_senioritydate, 
 		   mpp_terminationdt = mp2.mpp_terminationdt, 
 		   mpp_address1 = mp2.mpp_address1, 
 		   mpp_address2 = mp2.mpp_address2, 
 		   mpp_city = mp2.mpp_city, 
 		   mpp_zip = mp2.mpp_zip, 
		   mpp_misc1 = mp2.mpp_misc1,
		   mpp_misc2 = mp2.mpp_misc2,
		   mpp_misc3 = mp2.mpp_misc3,
		   mpp_misc4 = mp2.mpp_misc4,
		   mpp_currentphone = mp2.mpp_currentphone, 
		   mpp_homephone = mp2.mpp_homephone, 
		   mpp_emername = mp2.mpp_emername, 
		   mpp_emerphone = mp2.mpp_emerphone, 
		   mpp_licensenumber = mp2.mpp_licensenumber, 
		   mpp_licenseclass = mp2.mpp_licenseclass, 
		   mpp_licensestate = mp2.mpp_licensestate, 
 		   mpp_employeetype = mp2.mpp_employeetype, 
 		   mpp_ssn = mp2.mpp_ssn 
 	  FROM #temp mp2
 	 WHERE mpp_id = @OldAsgn_id
 	 
 	DROP TABLE #temp
 	 
	--Delete from ID from manpowerprofile_CA_OT_rules table
	if Exists(select name from sysobjects where name = 'manpowerprofile_CA_OT_rules')
		DELETE FROM manpowerprofile_CA_OT_rules WHERE mpp_id = @NewAsgn_id

	--Delete duplicate driver ID
	DELETE FROM manpowerprofile
	 WHERE mpp_id = @NewAsgn_id

IF (SELECT COUNT(*) FROM manpowerprofile WHERE mpp_id = @NewAsgn_id) > 0 
BEGIN
	ROLLBACK TRANSACTION MasterFileUpdate
	INSERT INTO DriverReplaceLog (drl_existingid, drl_newid, drl_user, drl_date, drl_tripschanged, drl_comment)
						  VALUES (@OldAsgn_id, @NewAsgn_id, USER_NAME(), GETDATE(), 0, 'FAILURE')
	set @returnValue = -7
END
ELSE
BEGIN
	COMMIT TRANSACTION MasterFileUpdate
	INSERT INTO DriverReplaceLog (drl_existingid, drl_newid, drl_user, drl_date, drl_tripschanged, drl_comment)
						  VALUES (@OldAsgn_id, @NewAsgn_id, USER_NAME(), GETDATE(), @RecordsToChange, 'SUCCESS')
	set @returnValue = 0
END

ExitProc:
select @returnValue "Return"

GO
GRANT EXECUTE ON  [dbo].[ReplaceDriverInSystem] TO [public]
GO
