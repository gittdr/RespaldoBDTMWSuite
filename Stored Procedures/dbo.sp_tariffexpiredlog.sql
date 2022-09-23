SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE proc [dbo].[sp_tariffexpiredlog]

as

insert into tariffrate_expired (tar_number,trc_number_row, trc_number_col, tra_rate,tra_retired, active, last_update)

select tar_number, trc_number_row, trc_number_col,tra_rate,isnull(tra_remarks4,tra_retired) ,'yes',getdate() from tariffrate where datediff(day,tra_retired,getdate())= 0

update tariffrate set tra_retired = '2049-12-31 23:59:59.000' where datediff(day,tra_retired,getdate())= 0


update tariffrate_expired set [row] = (select case when trc_matchvalue like '°%' then trc_multimatch else trc_matchvalue end from tariffrowcolumn where cast(trc_number  as varchar(20)) = trc_number_row and trc_rowcolumn = 'R' ),
[column] =   (select case when trc_matchvalue like '°%' then trc_multimatch else trc_matchvalue end from tariffrowcolumn where cast(trc_number as varchar(20)) = trc_number_col and trc_rowcolumn = 'C' )
where ([row] is null) or ( [column] is null)

update tariffrate_expired set  active = 'no', last_update = getdate() where (cast(tar_number as varchar(20)) + cast(trc_number_row as varchar(20)) + cast(trc_number_col as varchar(20)))  
in (select  (cast(tar_number as varchar(20)) + cast(trc_number_row as varchar(20)) + cast(trc_number_col as varchar(20)))  from tariffrate where tra_retired <> '2049-12-31 23:59:59.000')



GO
