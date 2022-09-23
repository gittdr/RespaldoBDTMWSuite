SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE Procedure [dbo].[check_expirations_sp]
	@idtype		CHAR(3), 
	@id		VARCHAR(13), 
	@trip_startdate	DATETIME,
	@trip_enddate	DATETIME,
	@id_pri1now	INTEGER	OUTPUT,
	@id_pri2now	INTEGER	OUTPUT
AS
BEGIN

DECLARE	@apocalypse	datetime

SELECT	@apocalypse = '12/31/2049 11:59:00 PM'

SELECT	@id_pri1now = COUNT(*)
FROM	expiration e (NOLOCK),
		labelfile l (NOLOCK)
WHERE	e.exp_idtype = @idtype AND
	e.exp_id = @id AND
	e.exp_completed = 'N' AND
	e.exp_priority = '1' AND
	e.exp_code = l.abbr and
	l.labeldefinition = 	(CASE @idtype
			WHEN 'CAR' THEN 'CarExp'
			WHEN 'DRV' THEN 'DrvExp'
			WHEN 'TRC' THEN 'TrcExp'
			WHEN 'TRL' THEN 'TrlExp'
			 END) AND
	((@trip_startdate < e.exp_expirationdate AND @trip_enddate > e.exp_expirationdate) OR
	(@trip_startdate >= e.exp_expirationdate AND @trip_startdate < (CASE ISNULL(l.auto_complete, 'N')
								WHEN 'Y' THEN e.exp_compldate
								ELSE @apocalypse END)))

SELECT	@id_pri2now = COUNT(*)
FROM	expiration e (NOLOCK),
		labelfile l (NOLOCK)
WHERE	e.exp_idtype = @idtype AND
	e.exp_id = @id AND
	e.exp_completed = 'N' AND
	e.exp_priority > '1' AND
	e.exp_code = l.abbr and
	l.labeldefinition = 	(CASE @idtype
			WHEN 'CAR' THEN 'CarExp'
			WHEN 'DRV' THEN 'DrvExp'
			WHEN 'TRC' THEN 'TrcExp'
			WHEN 'TRL' THEN 'TrlExp'
			 END) AND
	((@trip_startdate < e.exp_expirationdate AND @trip_enddate > e.exp_expirationdate) OR
	(@trip_startdate >= e.exp_expirationdate AND @trip_startdate < (CASE ISNULL(l.auto_complete, 'N')
								WHEN 'Y' THEN e.exp_compldate
								ELSE @apocalypse END)))
END
GO
GRANT EXECUTE ON  [dbo].[check_expirations_sp] TO [public]
GO
