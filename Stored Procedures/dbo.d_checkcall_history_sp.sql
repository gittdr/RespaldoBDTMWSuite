SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_checkcall_history_sp] (@p_count int,
                                         @p_drv varchar(8) = 'UNKNOWN', 
                                         @p_trc varchar(8) = 'UNKNOWN', 
                                         @p_trl varchar(13)= 'UNKNOWN', 
                                         @p_sort_order varchar(3) = 'DAT') 
AS

/**
 * 
 * NAME:
 * dbo.d_checkcall_history_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns the last x number of checkcalls for all resources specified
 *
 * RETURNS:
 * NONE 
 *
 * RESULT SETS: 
 * ckc_number
 * ckc_comment
 * ckc_date
 * ckc_asgntype
 * ckc_asgnid
 *
 * PARAMETERS:
 * 001 - @p_count, int, input, null;
 *       This parameter indicates the number of checkcalls to be retrieved for each resource (restricted to a max of 20)
 * 002 - @p_drv, varchar(8), input, null;
 *       This parameter indicates the driver to be used for retrieval
 * 003 - @p_trc, varchar(18), input, null;
 *       This parameter indicates the tractor to be used for retrieval
 * 004 - @p_trl, varchar(18), input, null;
 *       This parameter indicates the trailer to be used for retrieval
 *
 * 
 * REVISION HISTORY:
 * 02/27/2006 ? PTS27424 - Jason Bauwin ? Original
 *
 **/

declare @checkcalls table (ckc_number int, ckc_comment varchar(255), ckc_date datetime, ckc_asgntype varchar(6), ckc_asgnid varchar(13), sort_number int)

if @p_count > 20 OR @p_count < 1
begin
   set @p_count = 20
end

set rowcount @p_count

if isnull(@p_drv, 'UNK') <> 'UNK' AND @p_drv <> 'UNKNOWN'
begin
   insert into @checkcalls 
   select ckc_number, isnull(ckc_comment,'') 'ckc_comment', ckc_date, ckc_asgntype, ckc_asgnid, CASE @p_sort_order WHEN 'DRV' THEN 1 ELSE 2 END
   from checkcall 
   where ckc_asgntype = 'DRV'
   and ckc_asgnid = @p_drv
   order by ckc_date desc
end
if isnull(@p_trc, 'UNK') <> 'UNK' AND @p_trc <> 'UNKNOWN'
begin
   insert into @checkcalls 
   select ckc_number, isnull(ckc_comment,'') 'ckc_comment', ckc_date, ckc_asgntype, ckc_asgnid, CASE @p_sort_order WHEN 'TRC' THEN 1 ELSE 2 END
   from checkcall 
   where ckc_asgntype = 'TRC'
   and ckc_asgnid = @p_trc
   order by ckc_date desc
end

if isnull(@p_trl, 'UNK') <> 'UNK' AND @p_trl <> 'UNKNOWN'
begin
   insert into @checkcalls 
   select ckc_number, isnull(ckc_comment,'') 'ckc_comment', ckc_date, ckc_asgntype, ckc_asgnid, CASE @p_sort_order WHEN 'TRL' THEN 1 ELSE 2 END
   from checkcall 
   where ckc_asgntype = 'TRL'
   and ckc_asgnid = @p_trl
   order by ckc_date desc
end

set rowcount 0

select ckc_number,
       ckc_comment,
       ckc_date,
       ckc_asgntype,
       ckc_asgnid
  from @checkcalls
 order by sort_number, ckc_date desc

GO
GRANT EXECUTE ON  [dbo].[d_checkcall_history_sp] TO [public]
GO
