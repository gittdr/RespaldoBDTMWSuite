SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[d_expirations_sp]
	@idtype VARCHAR(6),
	@idnumber VARCHAR(13),
	@exptype VARCHAR(6), @completed CHAR(1),
	@startdt DATETIME, @enddt DATETIME,
	@pairing CHAR(1)

AS
/**
 *
 * REVISION HISTORY:
 * 10/26/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 * 11/27/2007    - PTS39920 - JDS -  added create_move to #temp (read from label file)
 * 06/12/2008    - PTS42167 - TGRIFFIT - changes so that the result set includes the protect_flag column
 **/

BEGIN

DECLARE @type2    VARCHAR(3),
        @id2      VARCHAR(13),
        @exptype2 VARCHAR(6)

--PTS 26385 Add move number for later recording
DECLARE @temp TABLE
	(exp_code		VARCHAR(6) NULL,
	exp_lastdate		DATETIME NULL,
	exp_expirationdate	DATETIME NULL,
	exp_routeto		VARCHAR(12) NULL,
	exp_idtype		VARCHAR(3) NULL,
	exp_id			VARCHAR(13) NULL,
	exp_completed		CHAR(1) NULL,
	exp_priority		VARCHAR(6) NULL,
	exp_compldate		DATETIME NULL,
	code			INT NULL,
	exp_creatdate		DATETIME NULL,
	exp_updateby		VARCHAR(20) NULL,
	exp_updateon		DATETIME NULL,
	exptype			VARCHAR(6) NULL,
	exp_city		INT NULL,
	cty_nmstct		VARCHAR(25) NULL,
	exp_description		VARCHAR (100) NULL,
	exp_key			INT NULL,
	auto_complete		CHAR(1),
	mov_number		int NULL,
	create_move     char(1) NULL, -- PTS 39920
    protect_flag    char(1) NULL, -- TGRIFFIT 42167
    cai_id			int NULL,
    exp_recurrence  varchar(6) NULL--PTS64936 JJF 20130717
     ) 	/* 07/15/2010 MDH PTS 53054: Added */

-- if pairing, then find the pair asset
IF @pairing = 'Y'
BEGIN
     IF @idtype = 'TRC'
     BEGIN
          SELECT @type2 = 'DRV',
                 @exptype2 = 'DrvExp'
          SELECT @id2 = trc_driver
            FROM tractorprofile
           WHERE trc_number = @idnumber
     END
     ELSE
     BEGIN
          SELECT @type2 = 'TRC',
                 @exptype2 = 'TrcExp'
          SELECT @id2 = mpp_tractornumber
            FROM manpowerprofile
           WHERE mpp_id = @idnumber
     END
END

-- gather all incomplete expirations for the asset passed to the routine
IF @completed = 'N' OR @completed = 'B'
BEGIN
	--PTS 26385 Add move number for later recording
     INSERT INTO @temp
          SELECT exp_code,
                 exp_lastdate,
                 exp_expirationdate,
                 exp_routeto,
                 exp_idtype,
                 exp_id,
                 exp_completed,
                 exp_priority,
                 exp_compldate,
                 0,
                 exp_creatdate,
                 exp_updateby,
                 exp_updateon,
                 @exptype,
	         exp_city,
	         cty_nmstct,
                 exp_description,
		 exp_key,
		 'N',
		 mov_number,
		 NULL, -- PTS 39920
        'N',   -- TGRIFFIT 42167
        ISNULL (cai_id,0),	/* 07/15/2010 MDH PTS 53054: Added */
        exp_recurrence  --PTS64936 JJF 20130717
        FROM  expiration LEFT OUTER JOIN  city  ON  exp_city  = city.cty_code
	  WHERE	 exp_idtype  = @idtype AND
                 exp_id  = @idnumber AND
                 exp_completed  = 'N'
                 /* 07/15/2010 MDH PTS 53054: Done client side now: AND ISNULL(cai_id, 0) = 0 */

     IF @pairing = 'Y'
	--PTS 26385 Add move number for later recording
        INSERT INTO @temp
             SELECT exp_code,
                    exp_lastdate,
                    exp_expirationdate,
                    exp_routeto,
                    exp_idtype,
                    exp_id,
                    exp_completed,
                    exp_priority,
                    exp_compldate,
                    0,
                    exp_creatdate,
                    exp_updateby,
                    exp_updateon,
                    @exptype2,
                    exp_city,
	            cty_nmstct,
		    exp_description,
		    exp_key,
		    'N',
		    mov_number,
		    NULL, -- PTS 39920
            'N',   -- TGRIFFIT 42167
        	ISNULL (cai_id,0),	/* 07/15/2010 MDH PTS 53054: Added */
        	exp_recurrence  --PTS64936 JJF 20130717
               FROM expiration LEFT OUTER JOIN  city  ON  exp_city  = city.cty_code
              WHERE exp_idtype = @type2 AND
                    exp_id = @id2 AND
                    exp_completed = 'N'
					/* 07/15/2010 MDH PTS 53054: Done client side now: AND ISNULL(cai_id, 0) = 0 */

END

-- gather all complete expirations for the asset passed to the routine in the given time frame
IF @completed = 'Y' OR @completed = 'B'
BEGIN
	--PTS 26385 Add move number for later recording
     INSERT INTO @temp
          SELECT exp_code,
                 exp_lastdate,
                 exp_expirationdate,
                 exp_routeto,
                 exp_idtype,
                 exp_id,
                 exp_completed,
                 exp_priority,
                 exp_compldate,
                 0,
                 exp_creatdate,
                 exp_updateby,
                 exp_updateon,
                 @exptype,
                 exp_city,
                 cty_nmstct,
		 exp_description,
                 exp_key,
			'N',
		 mov_number,
		 NULL, -- PTS 39920
         'N',   -- TGRIFFIT 42167
        ISNULL (cai_id,0),	/* 07/15/2010 MDH PTS 53054: Added */
        exp_recurrence  --PTS64936 JJF 20130717
            FROM expiration LEFT OUTER JOIN  city  ON  exp_city  = city.cty_code
           WHERE exp_idtype = @idtype AND
                 exp_id = @idnumber AND
                 exp_completed = 'Y' AND
                 isnull(exp_compldate, '12/31/49') BETWEEN @startdt AND @enddt
                 /* 07/15/2010 MDH PTS 53054: Done client side now: AND ISNULL(cai_id, 0) = 0 */
			
     IF @pairing = 'Y'
		--PTS 26385 Add move number for later recording
        INSERT INTO @temp
             SELECT exp_code,
                    exp_lastdate,
                    exp_expirationdate,
                    exp_routeto,
                    exp_idtype,
                    exp_id,
                    exp_completed,
                    exp_priority,
                    exp_compldate,
                    0,
                    exp_creatdate,
                    exp_updateby,
                    exp_updateon,
                    @exptype2,
                    exp_city,
                    cty_nmstct,
		    exp_description,
	 	    exp_key,
		    'N',
		    mov_number,
		    NULL, -- PTS 39920
            'N',   -- TGRIFFIT 42167
      	  ISNULL (cai_id,0),	/* 07/15/2010 MDH PTS 53054: Added */
      	  exp_recurrence  --PTS64936 JJF 20130717
               FROM expiration LEFT OUTER JOIN  city  ON  exp_city  = city.cty_code
              WHERE exp_idtype = @type2 AND
                    exp_id = @id2 AND
                    exp_completed = 'Y' AND
                    isnull(exp_compldate, '12/31/49') BETWEEN @startdt AND @enddt
                    /* 07/15/2010 MDH PTS 53054: Done client side now: AND ISNULL(cai_id, 0) = 0 */
END

UPDATE	@temp
SET	code = l.code,
	auto_complete = ISNULL(l.auto_complete,'N'),
	create_move  = ISNULL(l.create_move, 'N')	-- PTS 39920
FROM	labelfile l
WHERE	exp_code = abbr AND
	labeldefinition = exptype

-- TGRIFFIT 42167
UPDATE @temp
SET protect_flag = 'Y'
WHERE exp_code IN
(SELECT abbr FROM labelfile
 WHERE labeldefinition = @exptype + 'Protect')
-- END TGRIFFIT 42167

--PTS 26385 Add move number for later recording
SELECT exp_code drv_code,
       exp_code trc_code,
       exp_code trl_code,
       exp_code car_code,
       exp_code,
       exp_lastdate,
       exp_expirationdate,
       exp_routeto,
       exp_idtype,
       exp_id,
       exp_completed,
       exp_priority,
       exp_compldate,
       code,
       exp_creatdate,
       exp_updateby,
       exp_updateon,
       exp_code cmp_code,
       exp_code tpr_code,
       exp_city,
       cty_nmstct,
       exp_description,
       exp_key,
       auto_complete,
       mov_number,
       create_move, -- PTS 39920
       protect_flag, -- TGRIFFIT 42167
       cai_id,	/* 07/15/2010 MDH PTS 53054: Added */
       exp_recurrence --PTS64936 JJF 20130717
  FROM @temp



END
GO
GRANT EXECUTE ON  [dbo].[d_expirations_sp] TO [public]
GO
