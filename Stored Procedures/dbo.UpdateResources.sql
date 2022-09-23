SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[UpdateResources] as

/**
 * 
 * NAME:
 * dbo.UpdateResources
 *
 * TYPE:
 * [StoredProcedure]
 *
 * DESCRIPTION:
 * This procedure updates resource tables, tractorprofile, manpowerprofile, and trailerprofile
 * with current value for the Terminal field from the database table resourcetracking.
 * This proc will be on a schedule to run nightly.
 *
 * RETURNS:
 * Nothing.
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * none.
 *
 * REFERENCES: 
 * none.
 * 
 * REVISION HISTORY:
 * Date ? 	PTS# - 	AuthorName	 ? Revision Description
 * 10/24/2006	34169	SLM		Initial Creation of Stored Procedure for Transwood to 
 *					populate terminal database column of Driver, Tractor and Trailer Profile tables
 *					from the resourcetracking database table
 **/

declare 
@lres_type      varchar(6),	-- These values are DRV, TRC, TRL from the labelfile asstype
@lres_id        varchar(8)	-- These values are the asstype id numbers

--Select res_id and most recent effective date for the interval
create table #tempresource
( res_type           varchar(6),
  res_id             varchar(8),
  res_classification varchar(20),
  res_effdatetime    datetime
)
insert into #tempresource (res_type, res_id, res_classification, res_effdatetime)
	select r.res_type, r.res_id, r.res_classification, res_effdatetime
	from resourcetracking r 
	where r.res_effdatetime = (select max (r2.res_effdatetime) 
				from resourcetracking r2
				where r2.res_id = r.res_id
				and r2.res_type = r.res_type )
	and r.res_classificationtype = 'Terminal' and (r.res_type = 'DRV' or r.res_type = 'TRC' or r.res_type = 'TRL')
	order by r.res_type

	-- Update manpowerprofile
	update manpowerprofile 
	set mpp_terminal = res_classification
        from #tempresource
	where mpp_id         = res_id 
	and res_type         = 'DRV'
	and res_effdatetime <= GETDATE()
        and mpp_terminal <> res_classification

	-- Update tractorprofile
	update tractorprofile
	set trc_terminal = res_classification
        from #tempresource
        where trc_number     = res_id
	and res_type         = 'TRC'
	and res_effdatetime <= GETDATE()
        and trc_terminal <> res_classification

	-- Update trailerprofile
	update trailerprofile
	set trl_terminal = res_classification
        from #tempresource
        where trl_number     = res_id
	and res_type         = 'TRL'
	and res_effdatetime <= GETDATE()
        and trl_terminal <> res_classification

grant execute on dbo.UpdateResources to public
GO
