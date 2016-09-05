import pytest
import kitti_formatter.formatter as formatter


@pytest.mark.parametrize('line,coords', [
    (['5 6 20 22\n'], [[5, 6, 20, 22]]),
    (['0 0 200 300\n', '10 20 30 40'], [[0, 0, 200, 300], [10, 20, 30, 40]]),
    (['0 0 200 300\n'], [[0, 0, 200, 300]]),
])
def test_parse_input(line, coords):
    assert formatter.parse_input(line) == coords
