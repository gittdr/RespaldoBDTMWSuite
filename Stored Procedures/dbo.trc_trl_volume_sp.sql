SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[trc_trl_volume_sp] @trc varchar(10), @trl1 varchar (13), @trl2 varchar (13)    as 

create table #volume (
type	varchar(4) not null,
compartment int not null,
vol int null,
cnt int null)

Insert into #volume
SELECT 'TRC' type, 
		trc_det_compartment, 
		trc_det_vol, 
		(select max(trc_det_compartment) from tractor_detail where trc_id = @trc) cnt 
FROM tractor_detail  
WHERE trc_id = @trc

If @trl1 <> ''
	Insert into #volume
	SELECT 'TRL1' type, 
			trl_det_compartment, 
			trl_det_vol, 
			(select max(trl_det_compartment) from trailer_detail where trl_id = @trl1) cnt  
	FROM trailer_detail  
	WHERE trl_id = @trl1

If @trl2 <> ''
	Insert into #volume
	SELECT 'TRL2' type, 
			trl_det_compartment, 
			trl_det_vol, 
			(select max(trl_det_compartment) from trailer_detail where trl_id = @trl2) cnt  
	FROM trailer_detail  
	WHERE trl_id = @trl2

select * from #volume
drop table #volume

GO
GRANT EXECUTE ON  [dbo].[trc_trl_volume_sp] TO [public]
GO
