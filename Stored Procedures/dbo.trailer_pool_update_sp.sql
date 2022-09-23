SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[trailer_pool_update_sp] AS
/*	Update trailerpool_bulkm table on everyday basis	*/
DECLARE	@last_update	datetime,
	@days_count	int 
SELECT	@last_update = max(pol_last_update) 
FROM	trailerpool_bulkm 
SELECT	@days_count = datediff(day, @last_update, getdate())
INSERT 	trailerpool_bulkm
SELECT	trl_id, trl_terminal, trl_type1, 
	1, trl_avail_date, trl_avail_date, getdate()
FROM 	trailerprofile
WHERE	trl_id not in (SELECT pol_trailer_id
			FROM 	trailerpool_bulkm)
			INSERT 	trailerpool_bulkm
SELECT	trl_id, trl_terminal, trl_type1, 
	1, trl_avail_date, trl_avail_date, getdate()
FROM 	trailerprofile t, trailerpool_bulkm p
WHERE	t.trl_id = p.pol_trailer_id and
	(t.trl_terminal <> p.pol_terminal or
	 t.trl_type1 <> p.pol_pool)
UPDATE 	trailerpool_bulkm
SET	pol_days_at = (datediff(day, pol_arrival_date, t.trl_avail_date) + 1),
	pol_depart_date = t.trl_avail_date,
	pol_last_update = getdate()
FROM 	trailerprofile t 
WHERE	t.trl_id = pol_trailer_id and
	t.trl_terminal = pol_terminal and
	dateadd(day, 1, pol_depart_date) <> t.trl_avail_date and
	t.trl_type1 = pol_pool

GO
GRANT EXECUTE ON  [dbo].[trailer_pool_update_sp] TO [public]
GO
