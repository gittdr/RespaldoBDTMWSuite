SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE view [dbo].[vista_fact_parcel_cadena_devoluciones]
as

SELECT distinct o.ord_number as Orden ,
(select replace(replace(replace(replace(replace(replace(MAX(rutaxml),'folio=A','folio='),'folio=B','folio='),'folio=C','folio='),'folio=D','folio='),'folio=E','folio='),'folio=F','folio=') from VISTA_fe_generadas where rutaxml LIKE '%folio=_%' and orden  =  o.ord_hdrnumber and serie='TDRT' ) as tralixxmlfact
 from orderheader o 
   where o.ord_hdrnumber  in (
--666452,
--662497,
--650978,
--666042,
--665441,
--652333,
--655189,
--622944,
650747,
652002,
649251,
--609428,
659075,
659384,
--604623,
--650469,
--624788,
656364,
656005,
644666,
659931
--664369
--662596,
--662223
--661533
--649945


--661288,
--661010,
--661289,
--661532,
--661539,
--659638,
--663263,
--663258,
--657850,
--659110,
--657692,
--657019,
--657851,
--664369,
--659639,
--659379,
--665390,
--663582,
--659931,
--661533,
--662596,
--662223
   )

GO
