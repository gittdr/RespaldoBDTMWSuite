SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[IntegrationServiceOptimizationRequests_LegHeaders] as 
	SELECT legs.[Id], [OptimizationRequestId], [IsLocked], [IsProcessed], 
		   legs.[LegHeaderNumber], [OrderHeaderNumber], [OptimizedLegHeaderNumber], 
		   [ShipWithGroupName], [SendCommodityCode], [SendReferenceNumbers], [RouteId], [LoadId], [AdditionalInfo], 
		   [Sending], [Sent], [SendingMessages], 
		   [LoadCallBackStart], [LoadCallBackEnd], [LoadCallBackStatus], [LoadCallBackBatchTransactionNumber], 
		   [LoadCallBackAssigned], [LoadCallBackConsolidation], [LoadCallBackCrossDock], 
		   [CallBackRatingStart], [CallBackRatingEnd], [CallBackRatingStatus], [CallBackRatingMessages], 
		   [OrderCallBackStart], [OrderCallBackEnd], [OrderCallBackStatus], 
		   [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn] 
	  FROM IntegrationServiceOptimizationRequestsLegHeaders legs LEFT OUTER JOIN IntegrationServiceOptimizationRequestsRequestStatus requests ON (legs.[Id] = requests.[RequestLegHeadersId] 
																	AND requests.[Id] = (SELECT MAX([Id]) FROM IntegrationServiceOptimizationRequestsRequestStatus requests2 WHERE legs.[Id] = requests2.[Id] 
																	AND legs.[LegHeaderNumber] = requests2.[LegHeaderNumber])) 
																 LEFT OUTER JOIN IntegrationServiceOptimizationRequestsLoadData loads ON (legs.[Id] = loads.[RequestLegHeadersId]) 
																 LEFT OUTER JOIN IntegrationServiceOptimizationRequestsOrderData orders ON (legs.[Id] = orders.[RequestLegHeadersId] 
																   AND orders.[Id] = (SELECT MAX([Id]) FROM IntegrationServiceOptimizationRequestsOrderData orders2 WHERE legs.[Id] = orders2.[Id])) 
GO
GRANT DELETE ON  [dbo].[IntegrationServiceOptimizationRequests_LegHeaders] TO [public]
GO
GRANT INSERT ON  [dbo].[IntegrationServiceOptimizationRequests_LegHeaders] TO [public]
GO
GRANT REFERENCES ON  [dbo].[IntegrationServiceOptimizationRequests_LegHeaders] TO [public]
GO
GRANT SELECT ON  [dbo].[IntegrationServiceOptimizationRequests_LegHeaders] TO [public]
GO
GRANT UPDATE ON  [dbo].[IntegrationServiceOptimizationRequests_LegHeaders] TO [public]
GO
