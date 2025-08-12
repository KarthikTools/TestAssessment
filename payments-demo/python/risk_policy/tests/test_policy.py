"""
MagicMock unit tests for risk policy module.
These tests run in milliseconds with zero network calls.
"""

import pytest
from unittest.mock import MagicMock, patch
from app.policy import RiskPolicy, decide, ExternalScoreClient


class TestRiskPolicy:
    """Test the RiskPolicy class with MagicMock."""
    
    def test_approve_fast_no_network(self):
        """Test approval path with mocked client."""
        client = MagicMock(spec=ExternalScoreClient)
        client.get_score.return_value = 90
        
        policy = RiskPolicy(client)
        score, decision = policy.decide("CUST123", 100.50)
        
        assert decision == "APPROVE"
        assert score == 90
        client.get_score.assert_called_once_with("CUST123", 100.50)
    
    def test_review_branch(self):
        """Test review path with mocked client."""
        client = MagicMock(spec=ExternalScoreClient)
        client.get_score.return_value = 75
        
        policy = RiskPolicy(client)
        score, decision = policy.decide("CUSTX", 55.0)
        
        assert decision == "REVIEW"
        assert score == 75
        client.get_score.assert_called_once_with("CUSTX", 55.0)
    
    def test_reject_branch(self):
        """Test rejection path with mocked client."""
        client = MagicMock(spec=ExternalScoreClient)
        client.get_score.return_value = 60
        
        policy = RiskPolicy(client)
        score, decision = policy.decide("CUSTY", 25.0)
        
        assert decision == "REJECT"
        assert score == 60
        client.get_score.assert_called_once_with("CUSTY", 25.0)
    
    def test_timeout_path(self):
        """Test timeout handling with mocked client."""
        client = MagicMock(spec=ExternalScoreClient)
        client.get_score.side_effect = TimeoutError("simulated timeout")
        
        policy = RiskPolicy(client)
        
        with pytest.raises(TimeoutError, match="simulated timeout"):
            policy.decide("CUST123", 10.0)
        
        client.get_score.assert_called_once_with("CUST123", 10.0)
    
    def test_network_error_path(self):
        """Test network error handling with mocked client."""
        client = MagicMock(spec=ExternalScoreClient)
        client.get_score.side_effect = ConnectionError("network down")
        
        policy = RiskPolicy(client)
        
        with pytest.raises(ConnectionError, match="network down"):
            policy.decide("CUST123", 50.0)
    
    def test_boundary_values(self):
        """Test boundary values for decision thresholds."""
        client = MagicMock(spec=ExternalScoreClient)
        policy = RiskPolicy(client)
        
        # Test boundary at 85 (APPROVE)
        client.get_score.return_value = 85
        score, decision = policy.decide("CUST1", 100.0)
        assert decision == "APPROVE"
        assert score == 85
        
        # Test boundary at 84 (REVIEW)
        client.get_score.return_value = 84
        score, decision = policy.decide("CUST2", 100.0)
        assert decision == "REVIEW"
        assert score == 84
        
        # Test boundary at 70 (REVIEW)
        client.get_score.return_value = 70
        score, decision = policy.decide("CUST3", 100.0)
        assert decision == "REVIEW"
        assert score == 70
        
        # Test boundary at 69 (REJECT)
        client.get_score.return_value = 69
        score, decision = policy.decide("CUST4", 100.0)
        assert decision == "REJECT"
        assert score == 69


class TestLegacyFunction:
    """Test the legacy decide function."""
    
    def test_legacy_function_works(self):
        """Test that legacy function still works."""
        client = MagicMock(spec=ExternalScoreClient)
        client.get_score.return_value = 88
        
        score, decision = decide("CUST123", 150.0, client)
        
        assert decision == "APPROVE"
        assert score == 88
        client.get_score.assert_called_once_with("CUST123", 150.0)


class TestMagicMockFeatures:
    """Test various MagicMock features and assertions."""
    
    def test_call_count_tracking(self):
        """Test that MagicMock tracks call counts correctly."""
        client = MagicMock(spec=ExternalScoreClient)
        client.get_score.return_value = 80
        
        policy = RiskPolicy(client)
        
        # Make multiple calls
        policy.decide("CUST1", 100.0)
        policy.decide("CUST2", 200.0)
        policy.decide("CUST3", 300.0)
        
        assert client.get_score.call_count == 3
        assert client.get_score.call_args_list == [
            (("CUST1", 100.0),),
            (("CUST2", 200.0),),
            (("CUST3", 300.0),)
        ]
    
    def test_mock_reset(self):
        """Test that mocks can be reset between tests."""
        client = MagicMock(spec=ExternalScoreClient)
        client.get_score.return_value = 90
        
        policy = RiskPolicy(client)
        policy.decide("CUST1", 100.0)
        
        assert client.get_score.call_count == 1
        
        # Reset the mock
        client.reset_mock()
        assert client.get_score.call_count == 0
        
        # Set new return value
        client.get_score.return_value = 70
        policy.decide("CUST2", 200.0)
        
        assert client.get_score.call_count == 1
        assert client.get_score.return_value == 70
    
    def test_side_effect_sequence(self):
        """Test side effect with sequence of values."""
        client = MagicMock(spec=ExternalScoreClient)
        client.get_score.side_effect = [85, 75, 65, 95]
        
        policy = RiskPolicy(client)
        
        # First call returns 85 -> APPROVE
        score, decision = policy.decide("CUST1", 100.0)
        assert decision == "APPROVE"
        assert score == 85
        
        # Second call returns 75 -> REVIEW
        score, decision = policy.decide("CUST2", 200.0)
        assert decision == "REVIEW"
        assert score == 75
        
        # Third call returns 65 -> REJECT
        score, decision = policy.decide("CUST3", 300.0)
        assert decision == "REJECT"
        assert score == 65
        
        # Fourth call returns 95 -> APPROVE
        score, decision = policy.decide("CUST4", 400.0)
        assert decision == "APPROVE"
        assert score == 95


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
