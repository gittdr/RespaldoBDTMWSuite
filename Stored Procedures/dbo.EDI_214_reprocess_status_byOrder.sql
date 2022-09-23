SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[EDI_214_reprocess_status_byOrder] @ord_hdrnumber INT
	
AS
/*
 * 
 * NAME:
 * dbo.EDI_214_reprocess_status_byOrder
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * reprocess arrival/departure 214 status events by order.  Based on current stop status.
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * NONE
 *
 * PARAMETERS:
 * NONE
 *
 * REFERENCES:
 * 
 * 
 * REVISION HISTORY:
 *
 */
 DECLARE @v_stp_number INT,
		 @v_stp_type VARCHAR(6),
		 @v_stp_arrivalstatus VARCHAR(6),
		 @v_stp_departurestatus VARCHAR(6),
		 @v_stp_arrivaldate DATETIME,
		 @v_stp_departuredate DATETIME,
		 @v_stp_earlydate DATETIME,
		 @v_stp_latedate DATETIME,
		 @v_stp_sequence INT,
		 @ps_activity VARCHAR(6),
		 @ps_level		  VARCHAR(6),
		 @ord_billto VARCHAR(8),
		 @EDI_Notification_Process_Type varchar(1),
		 @firstlastflags varchar(20),
		 @ReplicateForEachDropFlag char(1),
		 @match_count int,
		 @e214Date DATETIME,
		 @arrive_earlyorlate CHAR(1),
		 @depart_earlyorlate CHAR(1),
		 @slacktime SMALLINT,
		 @stop_activity VARCHAR(6),
		 @appName NVARCHAR(128),
		 @tmwUser VARCHAR(255)
		 
 --determine billto for TP match
 SELECT @ord_billto =  ord_billto
 FROM orderheader with(NOLOCK)
 WHERE ord_hdrnumber = @ord_hdrnumber
 
SELECT @EDI_Notification_Process_Type = isnull(gi_string1,1)
FROM generalinfo
WHERE gi_name = 'EDI_Notification_Process_Type'	

SELECT  @slacktime = convert(smallint,ISNULL(gi_string1,'0'))
FROM    generalinfo
WHERE   gi_name = 'SlackTime'

SELECT @firstlastflags = '0,1,99'

SELECT @appName = 'EDI LTSL2'
EXEC gettmwuser @tmwUser OUTPUT
 
--begin processing loop for stops.  
--	1.send arrival/departure status for stop
DECLARE STOPDATA_CURSOR cursor fast_forward for
SELECT 	stp_number,
		stp_type,
		stp_status,
		stp_departure_status,
		stp_arrivaldate,
		stp_departuredate,
		stp_schdtearliest,
		stp_schdtlatest,
		stp_sequence,
		stp_event
FROM stops with(NOLOCK)
WHERE ord_hdrnumber = @ord_hdrnumber 
ORDER BY stp_sequence ASC

OPEN STOPDATA_CURSOR

FETCH NEXT FROM STOPDATA_CURSOR
INTO @v_stp_number ,@v_stp_type ,@v_stp_arrivalstatus, @v_stp_departurestatus , @v_stp_arrivaldate ,@v_stp_departuredate, @v_stp_earlydate ,
		 @v_stp_latedate , @v_stp_sequence , @ps_activity 

	WHILE @@FETCH_STATUS = 0
		BEGIN--1
		--get level for 214 output based on stop type
		SELECT @ps_level =  CASE @v_stp_type
							WHEN 'PUP' THEN 'SH'
							WHEN 'DRP' THEN 'CN'
							ELSE 'NON'
						 END

		--triggering activity based on stop status
		 SELECT @ps_activity =  CASE 
									WHEN @v_stp_departurestatus = 'DNE' THEN 'ARVDEP'
									WHEN @v_stp_arrivalstatus = 'DNE' AND @v_stp_departurestatus = 'OPN' THEN 'ARV'
									ELSE ' '
								END	
								
		--determine earlyor late flags
		SELECT @arrive_earlyorlate  = CASE 
										WHEN @v_stp_latedate < '20491231' AND 
											 DATEDIFF(mi,@v_stp_latedate,@v_stp_arrivaldate) > @slacktime
											THEN 'L'
										WHEN @v_stp_earlydate > '19500101' AND 
											 @v_stp_arrivaldate < @v_stp_earlydate
											 THEN 'E'
										ELSE ' '
									  END
	  SELECT @depart_earlyorlate = CASE
										WHEN @v_stp_latedate < '20491231' and 
												DATEDIFF(mi,@v_stp_latedate,@v_stp_departuredate) > @slacktime
										THEN 'L'
										ELSE ' '
									END	
										
		--Billto based EDI method
		IF @EDI_Notification_Process_Type = 1
		BEGIN--billto based EDI		
			SELECT @match_count = count(1), @ReplicateForEachDropFlag=Max(IsNull(e214_ReplicateForEachDropFlag,'N') ) 
			  FROM edi_214_profile
			WHERE e214_cmp_id=@ord_billto
			   AND e214_level = @ps_level 
			   AND CHARINDEX(e214_triggering_activity, @ps_activity) > 0
			   
			 IF @match_count > 0 
			  BEGIN
						SELECT @e214date = @v_stp_arrivaldate
						
						--insert arrival status record
						INSERT edi_214_pending (
			            e214p_ord_hdrnumber,
			            e214p_billto,
			            e214p_level,
			            e214p_ps_status,
			            e214p_stp_number,
			            e214p_dttm,
			            e214p_activity,
			            e214p_arrive_earlyorlate,
			            e214p_depart_earlyorlate,
			            e214p_stpsequence,
			            ckc_number,
			            e214p_firstlastflags,
						e214p_created,
						e214p_source,
					    e214p_user,
						e214p_ReplicateForEachDropFlag)
		              VALUES (@ord_hdrnumber,
			            @ord_billto,
			            @ps_level,
			            ' ',
			            @v_stp_number,
			            @e214date,
			            CASE @ps_activity
							WHEN 'ARVDEP' Then 'ARV'
							ELSE @ps_activity
							END,
			            @arrive_earlyorlate,
			            @depart_earlyorlate,
			            @v_stp_sequence,
			            0,
			            @firstlastflags,
						getdate(),
						@appName,
						@tmwUser,
						@ReplicateForEachDropFlag)
						
					IF @ps_activity = 'ARVDEP'
						INSERT edi_214_pending (
			           	 	e214p_ord_hdrnumber,
			            	e214p_billto,
			            	e214p_level,
			            	e214p_ps_status,
							e214p_stp_number,
			            	e214p_dttm,
			            	e214p_activity,
							e214p_arrive_earlyorlate,
			            	e214p_depart_earlyorlate,
							e214p_stpsequence,
							ckc_number,
							e214p_firstlastflags,
							e214p_created,
							e214p_source,
					        e214p_user,
							e214p_ReplicateForEachDropFlag)
		              	VALUES (@ord_hdrnumber,
								@ord_billto,
								@ps_level,
								' ',
								@v_stp_number,
								@v_stp_departuredate,
								'DEP',
								@arrive_earlyorlate,
								@depart_earlyorlate,
								@v_stp_sequence,
								0,
								@firstlastflags,
								getdate(),
								@appName,
						        @tmwUser,
								@ReplicateForEachDropFlag)	
						  
			  END
			  
		
		END--billto based EDI
		
	   IF @EDI_Notification_Process_Type = 2
	   BEGIN --company based EDI
		SELECT @e214date = @v_stp_arrivaldate
		IF @ps_activity = 'ARVDEP'
			SELECT @stop_activity = 'ARV'
		ELSE
			SELECT @stop_activity = @ps_activity
		
		INSERT edi_214_pending (
				e214p_ord_hdrnumber,
				e214p_billto,
				e214p_level,
				e214p_ps_status,
				e214p_stp_number,
				e214p_dttm,
				e214p_activity,
				e214p_arrive_earlyorlate,
				e214p_depart_earlyorlate,
				e214p_stpsequence,
				ckc_number,
				e214p_firstlastflags,
				e214p_created,
				e214p_source,
				e214p_user,
				e214p_ReplicateForEachDropFlag)
			SELECT distinct @ord_hdrnumber,
				e214_cmp_id,
				@ps_level,
				' ',
				@v_stp_number,
				@e214date,
				CASE @ps_activity
					WHEN 'ARVDEP' Then 'ARV'
					ELSE @ps_activity
				END,
				' ',
				' ',
				@v_stp_sequence,
				0,
				@firstlastflags,
				getdate(),
				@appName,
				@tmwUser,
				@ReplicateForEachDropFlag
				from edi_214_profile, stops
				where e214_level = @ps_level
				and ord_hdrnumber = @ord_hdrnumber
				and stp_type = 'PUP'
				and cmp_id = e214_cmp_id
				and shipper_role_flag = 'Y'
				and e214_triggering_activity = @stop_activity
			UNION
			SELECT distinct @ord_hdrnumber,
				e214_cmp_id,
				@ps_level,
				' ',
				@v_stp_number,
				@e214date,
				CASE @ps_activity
					WHEN 'ARVDEP' Then 'ARV'
					ELSE @ps_activity
				END,
				' ',
				' ',
				@v_stp_sequence,
				0,
				@firstlastflags,
				getdate(),
				@appName,
				@tmwUser,
				@ReplicateForEachDropFlag
				from edi_214_profile, stops
				where e214_level = @ps_level
				and ord_hdrnumber = @ord_hdrnumber
				and stp_type = 'DRP'
				and cmp_id = e214_cmp_id
				and consignee_role_flag = 'Y'
				and e214_triggering_activity = @stop_activity
			UNION
			SELECT @ord_hdrnumber,
				e214_cmp_id,
				@ps_level,
				' ',
				@v_stp_number,
				@e214date,
				CASE @ps_activity
					WHEN 'ARVDEP' Then 'ARV'
					ELSE @ps_activity
				END,
				' ',
				' ',
				@v_stp_sequence,
				0,
				@firstlastflags,
				getdate(),
				@appName,
				@tmwUser,
				@ReplicateForEachDropFlag
				from edi_214_profile, orderheader
				where e214_level = @ps_level
				and ord_hdrnumber = @ord_hdrnumber
				and e214_triggering_activity = @stop_activity
				and ord_billto = e214_cmp_id 
				and billto_role_flag = 'Y'
			UNION
			SELECT @ord_hdrnumber,
				e214_cmp_id,
				@ps_level,
				' ',
				@v_stp_number,
				@e214date,
				CASE @ps_activity
					WHEN 'ARVDEP' Then 'ARV'
					ELSE @ps_activity
				END,
				' ',
				' ',
				@v_stp_sequence,
				0,
				@firstlastflags,
				getdate(),
				@appName,
				@tmwUser,
				@ReplicateForEachDropFlag
				from edi_214_profile, orderheader
				where e214_level = @ps_level
				and ord_hdrnumber = @ord_hdrnumber
				and e214_triggering_activity = @stop_activity
				and ord_company = e214_cmp_id 
				and orderby_role_flag = 'Y'
				
			IF @ps_activity = 'ARVDEP'
				BEGIN --process DEP from ARVDEP
					SELECT @ps_activity = 'DEP'
					 INSERT edi_214_pending (
				            e214p_ord_hdrnumber,
				            e214p_billto,
				            e214p_level,
				            e214p_ps_status,
				            e214p_stp_number,
				            e214p_dttm,
				            e214p_activity,
				            e214p_arrive_earlyorlate,
				            e214p_depart_earlyorlate,
				            e214p_stpsequence,
				            ckc_number,
				            e214p_firstlastflags,
							e214p_created,
							e214p_source,
							e214p_user,
		                  	e214p_ReplicateForEachDropFlag)
					SELECT distinct
			                @ord_hdrnumber,
				            e214_cmp_id,
				            @ps_level,
				            ' ',
				            @v_stp_number,
				            @e214Date,
				            'DEP',
				            @arrive_earlyorlate,
				            @depart_earlyorlate,
				            @v_stp_sequence,
				            0,
				            @firstlastflags,
							getdate(),
							@appName,
							@tmwUser,
							@ReplicateForEachDropFlag
					from edi_214_profile with (nolock), stops with (nolock)
					where e214_level = @ps_level
					and ord_hdrnumber = @ord_hdrnumber
					and stp_type = 'PUP'
					and cmp_id = e214_cmp_id
					and shipper_role_flag = 'Y'
					and e214_triggering_activity = @ps_activity
					UNION
					SELECT distinct
			                @ord_hdrnumber,
				            e214_cmp_id,
				            @ps_level,
				            ' ',
				            @v_stp_number,
				            @e214Date,
				            'DEP',
				            @arrive_earlyorlate,
				            @depart_earlyorlate,
				            @v_stp_sequence,
				            0,
				            @firstlastflags,
							getdate(),
							@appName,
							@tmwUser,
							@ReplicateForEachDropFlag
					from edi_214_profile with (nolock), stops with (nolock)
					where e214_level = @ps_level
					and ord_hdrnumber = @ord_hdrnumber
					and stp_type = 'DRP'
					and cmp_id = e214_cmp_id
					and consignee_role_flag = 'Y'
					and e214_triggering_activity = @ps_activity
					UNION
					SELECT
			                    @ord_hdrnumber,
				            e214_cmp_id,
				            @ps_level,
				            ' ',
				            @v_stp_number,
				            @e214Date,
				            'DEP',
				            @arrive_earlyorlate,
				            @depart_earlyorlate,
				            @v_stp_sequence,
				            0,
				            @firstlastflags,
							getdate(),
							@appName,
							@tmwUser,
							@ReplicateForEachDropFlag
					from edi_214_profile with (nolock), orderheader with (nolock)
					where e214_level = @ps_level
					and ord_hdrnumber = @ord_hdrnumber
					and e214_triggering_activity = @ps_activity
					and ord_billto = e214_cmp_id
					and billto_role_flag = 'Y'
					UNION
					SELECT
			                    @ord_hdrnumber,
				            e214_cmp_id,
				            @ps_level,
				            ' ',
				            @v_stp_number,
				            @e214Date,
				            'DEP',
				            @arrive_earlyorlate,
				            @depart_earlyorlate,
				            @v_stp_sequence,
				            0,
				            @firstlastflags,
							getdate(),
							@appName,
							@tmwUser,
							@ReplicateForEachDropFlag
					from edi_214_profile with (nolock), orderheader with (nolock)
					where e214_level = @ps_level
					and ord_hdrnumber = @ord_hdrnumber
					and e214_triggering_activity = @ps_activity
					and ord_company = e214_cmp_id
					and orderby_role_flag = 'Y'
			
				END --ARVDEP Processing
	   
	   END --company Based EDI
		
		FETCH NEXT FROM STOPDATA_CURSOR
		INTO @v_stp_number ,@v_stp_type ,@v_stp_arrivalstatus, @v_stp_departurestatus , @v_stp_arrivaldate ,@v_stp_departuredate, @v_stp_earlydate ,
		 @v_stp_latedate , @v_stp_sequence , @ps_activity 
		
		END--1
	CLOSE STOPDATA_CURSOR
	DEALLOCATE	STOPDATA_CURSOR
	
GO
GRANT EXECUTE ON  [dbo].[EDI_214_reprocess_status_byOrder] TO [public]
GO
