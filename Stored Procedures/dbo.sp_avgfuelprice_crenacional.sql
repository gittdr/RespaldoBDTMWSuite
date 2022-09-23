SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[sp_avgfuelprice_crenacional]

as

insert into averagefuelprice 
(afp_tableid, afp_date, afp_description, afp_price)

select 
7,
getdate(),
'CRE NACIONAL MENSUAL',
round(avg(price_avg),2)
 from FUEL.[dbo].[price_gral_hist]
where month(date) = month(dateadd(month,-1,getdate())) 
and
year(date) = year(dateadd(month,-1,getdate())) 
GO
