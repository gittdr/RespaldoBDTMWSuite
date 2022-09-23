SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[dx_create_appointment214] (@p_OrdHdr int)
as

IF (SELECT LEFT(ISNULL(gi_string1,'N'), 1) FROM generalinfo WHERE gi_name = 'Auto214Flag') = 'Y'
BEGIN
	DECLARE @stp_number int, @ord_billto varchar(8), @ps_activity varchar(8), @stp_sequence int, 
		@firstlastflags varchar(20), @stp_latest datetime, @match_count int, 
		@level varchar(2), @ReplicateForEachDropFlag char(1), @EDI_Notification_Process_Type varchar(1),
		@appName NVARCHAR(128),@tmwUser VARCHAR(255)

	SELECT @EDI_Notification_Process_Type = isnull(gi_string1,1)
	FROM generalinfo
	WHERE gi_name = 'EDI_Notification_Process_Type'	

	SELECT @stp_number = 0
	WHILE 1=1
	BEGIN
		SELECT @stp_number = MIN(stp_number) FROM stops WHERE ord_hdrnumber = @p_OrdHdr and stp_number > @stp_number
		IF @stp_number IS NULL BREAK
		SELECT @ord_billto = orderheader.ord_billto,
			@ps_activity = 'APPT',
			@stp_sequence = stops.stp_sequence,
			@firstlastflags = '0,1,99', --stop position criteria aren't implemented; this criterion is also true
			@stp_latest = stops.stp_schdtlatest,
			@level = case stops.stp_type
				when 'PUP' then 'SH'
				when 'DRP' then 'CN'
				else 'NON'
				end
		  FROM stops, orderheader
		 WHERE stops.stp_number = @stp_number AND orderheader.ord_hdrnumber = @p_OrdHdr

		SELECT @match_count = count(1), @ReplicateForEachDropFlag=Max(IsNull(e214_ReplicateForEachDropFlag,'N') ) 
		  FROM edi_214_profile
		 WHERE e214_cmp_id=@ord_billto
		   AND e214_level = @level 
		   AND CHARINDEX(e214_triggering_activity, @ps_activity) > 0

		   SELECT @appName = 'EDI LTSL2'
		EXEC gettmwuser @tmwUser OUTPUT

		IF @EDI_Notification_Process_Type = '1' --trigger rules by billto
		BEGIN
			IF @match_count>0
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
				VALUES (@p_OrdHdr,
					@ord_billto,
					@level,
					' ',
					@stp_number,
					@stp_latest,
					@ps_activity,
					' ',
					' ',
					@stp_sequence,
					0,
					@firstlastflags,
					getdate(),
					@appName,
					@tmwUser,
					@ReplicateForEachDropFlag)
		END
		IF @EDI_Notification_Process_Type = '2'	--trigger rules by company
		BEGIN 
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
			SELECT distinct @p_OrdHdr,
				e214_cmp_id,
				@level,
				' ',
				@stp_number,
				@stp_latest,
				@ps_activity,
				' ',
				' ',
				@stp_sequence,
				0,
				@firstlastflags,
				getdate(),
				@appName,
				@tmwUser,
				@ReplicateForEachDropFlag
				from edi_214_profile, stops
				where e214_level = @level
				and ord_hdrnumber = @p_OrdHdr
				and stp_type = 'PUP'
				and cmp_id = e214_cmp_id
				and shipper_role_flag = 'Y'
				and e214_triggering_activity = @ps_activity
			UNION
			SELECT distinct @p_OrdHdr,
				e214_cmp_id,
				@level,
				' ',
				@stp_number,
				@stp_latest,
				@ps_activity,
				' ',
				' ',
				@stp_sequence,
				0,
				@firstlastflags,
				getdate(),
				@appName,
				@tmwUser,
				@ReplicateForEachDropFlag
				from edi_214_profile, stops
				where e214_level = @level
				and ord_hdrnumber = @p_OrdHdr
				and stp_type = 'DRP'
				and cmp_id = e214_cmp_id
				and consignee_role_flag = 'Y'
				and e214_triggering_activity = @ps_activity
			UNION
			SELECT @p_OrdHdr,
				e214_cmp_id,
				@level,
				' ',
				@stp_number,
				@stp_latest,
				@ps_activity,
				' ',
				' ',
				@stp_sequence,
				0,
				@firstlastflags,
				getdate(),
				@appName,
				@tmwUser,
				@ReplicateForEachDropFlag
				from edi_214_profile, orderheader
				where e214_level = @level
				and ord_hdrnumber = @p_OrdHdr
				and e214_triggering_activity = @ps_activity
				and ord_billto = e214_cmp_id 
				and billto_role_flag = 'Y'
			UNION
			SELECT @p_OrdHdr,
				e214_cmp_id,
				@level,
				' ',
				@stp_number,
				@stp_latest,
				@ps_activity,
				' ',
				' ',
				@stp_sequence,
				0,
				@firstlastflags,
				getdate(),
				@appName,
				@tmwUser,
				@ReplicateForEachDropFlag
				from edi_214_profile, orderheader
				where e214_level = @level
				and ord_hdrnumber = @p_OrdHdr
				and e214_triggering_activity = @ps_activity
				and ord_company = e214_cmp_id 
				and orderby_role_flag = 'Y'
		END
	END
END

GO
GRANT EXECUTE ON  [dbo].[dx_create_appointment214] TO [public]
GO
