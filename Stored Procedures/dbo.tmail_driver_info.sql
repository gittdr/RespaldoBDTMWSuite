SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  Stored Procedure dbo.tmail_driver_info    Script Date: 1/5/99 7:56:03 PM ******/
CREATE PROCEDURE [dbo].[tmail_driver_info] ( @mpp_id varchar(8), @ssn varchar(9) ) 

AS
 
/* 05/24/01 DAG: Converting for international date format */
/* 11/25/05 MIZ: Add Alt ID view field */

SET NOCOUNT ON 

DECLARE @logdate datetime, 
	@confirmSSN varchar(9),
	@alt_id varchar(8), 
	@altdate datetime

-- We have a SSN and mpp_id
IF isnull(@ssn, '') <> '' and isnull(@mpp_id , '') <> ''
	select @logdate = CONVERT(
				datetime,
				right(
					CONVERT(
						char(10),
						isnull(
							mpp_last_log_date,
							'19500101'),
						101),
					4)
				+left(
					CONVERT(
						char(10),
						isnull(
							mpp_last_log_date,
							'19500101'),
						101),
					2)
				+substring(
					CONVERT(
						char(10),
						isnull(
							mpp_last_log_date,
							'19500101'),
						101),
					4,
					2)),
		@alt_id = mpp_id 
	FROM manpowerprofile (NOLOCK)
	WHERE mpp_ssn = @ssn 
		AND mpp_id = @mpp_id

IF isnull(@alt_id, '') <> ''
	IF datediff(hh, isnull(@logdate, '19500101'), getdate()) > 48
		select -1 HoursToday, -1 HoursTomorrow, -1 HoursDay2, mpp_tractornumber LastTractor, mpp_lastfirst Name, 
			mpp_firstname, mpp_middlename, mpp_lastname ,mpp_id DriverID, mpp_ssn SSN, mpp_type1, mpp_type2, mpp_type3, 
			mpp_type4, mpp_otherid AltID, mpp_terminal
		from manpowerprofile (NOLOCK)
		where mpp_id = @alt_id
	ELSE
		select mpp_hours1 HoursToday, mpp_hours2 HoursTomorrow, mpp_hours3 HoursDay2, mpp_tractornumber LastTractor, mpp_lastfirst Name, 
			mpp_firstname, mpp_middlename, mpp_lastname, mpp_id DriverID, mpp_ssn SSN, mpp_type1, mpp_type2, mpp_type3, 
			mpp_type4, mpp_otherid AltID, mpp_terminal
		from manpowerprofile (NOLOCK)
		where mpp_id = @alt_id
ELSE
	IF isnull(@ssn, '') <> ''
	  BEGIN
		select @logdate = CONVERT(
					datetime,
					right(
						CONVERT(
							char(10),
							isnull(
								mpp_last_log_date,
								'19500101'),
							101),
						4)
					+left(
						CONVERT(
							char(10),
							isnull(
								mpp_last_log_date,
								'19500101'),
							101),
						2)
					+substring(
						CONVERT(
							char(10),
							isnull(
								mpp_last_log_date,
								'19500101'),
							101),
						4,
						2))
		from manpowerprofile 
		where mpp_ssn = @ssn

		if datediff(hh, isnull(@logdate, '19500101'), getdate()) > 48
			select -1 HoursToday, -1 HoursTomorrow, -1 HoursDay2, mpp_tractornumber LastTractor, mpp_lastfirst Name, 
				mpp_firstname, mpp_middlename, mpp_lastname, mpp_id DriverID, mpp_ssn SSN, mpp_type1, mpp_type2, mpp_type3, 
				mpp_type4, mpp_otherid AltID, mpp_terminal
			from manpowerprofile (NOLOCK)
			where mpp_ssn = @ssn
		else
			select mpp_hours1 HoursToday, mpp_hours2 HoursTomorrow, mpp_hours3 HoursDay2, mpp_tractornumber LastTractor, mpp_lastfirst Name, 
				mpp_firstname, mpp_middlename, mpp_lastname, mpp_id DriverID, mpp_ssn SSN, mpp_type1, mpp_type2, mpp_type3, 
				mpp_type4, mpp_otherid AltID, mpp_terminal
			from manpowerprofile (NOLOCK)
			where mpp_ssn = @ssn
	  END
	ELSE
	  BEGIN
		select @logdate = CONVERT(
					datetime,
					right(
						CONVERT(
							char(10),
							isnull(
								mpp_last_log_date,
								'19500101'),
							101),
						4)
					+left(
						CONVERT(
							char(10),
							isnull(
								mpp_last_log_date,
								'19500101'),
							101),
						2)
					+substring(
						CONVERT(
							char(10),
							isnull(
								mpp_last_log_date,
								'19500101'),
							101),
						4,
						2))
		from manpowerprofile (NOLOCK)
		where mpp_id = @mpp_id 
	
		if datediff(hh, isnull(@logdate, '19500101'), getdate()) > 48
			select -1 HoursToday, -1 HoursTomorrow, -1 HoursDay2, mpp_tractornumber LastTractor, mpp_lastfirst Name, 
				mpp_firstname, mpp_middlename, mpp_lastname, mpp_id DriverID, mpp_ssn SSN, mpp_type1, mpp_type2, mpp_type3, 
				mpp_type4, mpp_otherid AltID, mpp_terminal
			from manpowerprofile (NOLOCK)
			where mpp_id = @mpp_id 
		else
			select mpp_hours1 HoursToday, mpp_hours2 HoursTomorrow, mpp_hours3 HoursDay2, mpp_tractornumber LastTractor, mpp_lastfirst Name, 
				mpp_firstname, mpp_middlename, mpp_lastname, mpp_id DriverID, mpp_ssn SSN, mpp_type1, mpp_type2, mpp_type3, 
				mpp_type4, mpp_otherid AltID, mpp_terminal
			from manpowerprofile (NOLOCK)
			where mpp_id = @mpp_id 
	  END
GO
GRANT EXECUTE ON  [dbo].[tmail_driver_info] TO [public]
GO
