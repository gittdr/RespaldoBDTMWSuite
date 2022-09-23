SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.dw_notices    Script Date: 6/1/99 11:54:30 AM ******/
CREATE PROCEDURE [dbo].[dw_notices] @drv1 char(8), @drv2 char(8), @trc char(8), @trl1 char(13), @trl2 char(13), @car char(8), @reldate datetime
AS

SELECT @drv1 id,
	pri1soon = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'DRV' AND
				exp_id = @drv1 AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority = '1' ),
	pri2soon = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'DRV' AND
				exp_id = @drv1 AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority > '1' ),
	pri1now = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'DRV' AND
				exp_id = @drv1 AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority = '1' ),
	pri2now = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'DRV' AND
				exp_id = @drv1 AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority > '1' ),
	idtype = 'DRV'


INTO #tt
WHERE ( @drv1 <> 'UNKNOWN' AND @drv1 <> '' ) 

INSERT INTO #tt
SELECT @drv2 id,
	pri1soon = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'DRV' AND
				exp_id = @drv2 AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority = '1' ),
	pri2soon = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'DRV' AND
				exp_id = @drv2 AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority > '1' ),
	pri1now = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'DRV' AND
				exp_id = @drv2 AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority = '1' ),
	pri2now = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'DRV' AND
				exp_id = @drv2 AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority > '1' ),
	idtype = 'DRV'

WHERE ( @drv2 <> 'UNKNOWN' AND @drv2 <> '' ) 

INSERT INTO #tt
SELECT @trc id,
	pri1soon = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'TRC' AND
				exp_id = @trc AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority = '1' ),
	pri2soon = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'TRC' AND
				exp_id = @trc AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority > '1' ),
	pri1now = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'TRC' AND
				exp_id = @trc AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority = '1' ),
	pri2now = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'TRC' AND
				exp_id = @trc AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority > '1' ),
	idtype = 'TRC'

WHERE ( @trc <> 'UNKNOWN' AND @trc <> '' ) 

INSERT INTO #tt
SELECT @trl1 id,
	pri1soon = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'TRL' AND
				exp_id = @trl1 AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority = '1' ),
	pri2soon = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'TRL' AND
				exp_id = @trl1 AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority > '1' ),
	pri1now = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'TRL' AND
				exp_id = @trl1 AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority = '1' ),
	pri2now = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'TRL' AND
				exp_id = @trl1 AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority > '1' ),
	idtype = 'TRL'

INSERT INTO #tt
SELECT @trl2 id,
	pri1soon = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'TRL' AND
				exp_id = @trl2 AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority = '1' ),
	pri2soon = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'TRL' AND
				exp_id = @trl2 AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority > '1' ),
	pri1now = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'TRL' AND
				exp_id = @trl2 AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority = '1' ),
	pri2now = ( SELECT count (*) 
			FROM expiration
			WHERE exp_idtype = 'TRL' AND
				exp_id = @trl2 AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority > '1' ),
	idtype = 'TRL'

WHERE ( @trl2 <> 'UNKNOWN' AND @trl2 <> '' ) 

SELECT * from #tt



GO
GRANT EXECUTE ON  [dbo].[dw_notices] TO [public]
GO
