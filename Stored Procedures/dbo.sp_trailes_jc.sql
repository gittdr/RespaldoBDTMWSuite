SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[sp_trailes_jc]  --(@fechai datetime, @fechaf datetime,@token varchar(254))
--exec [dbo].[sp_trailes_jc] '2021-10-07T00:00:00', '2021-10-17T23:59:00', 'INTRA2501181256xTrFl33t'

as



declare @Trai xml

set @Trai = 
(

select * from(
select trl_number as Economico, 
(select replace(replace(name,'&',' AND '),'/','') from labelfile where labeldefinition = 'fleet' and abbr=  trl_fleet) as flota

 from trailerprofile
where trl_status <> 'OUT'
) as q


FOR XML PATH ('Tractor'), root ('Tractors')

)



select @Trai as Trailers

--exec sp_trailes_jc  '2021-10-07T00:00:00', '2021-10-17T23:59:00', 'INTRA2501181256xTrFl33t'
GO
