using System.Collections.Generic;
using UnityEngine;

namespace TestGPUInstancing
{
    public class DrawMeshInstancing : MonoBehaviour
    {
        [SerializeField] private Mesh _mesh;
        [SerializeField] private Material _material;
        [SerializeField] private float _areaWidth = 5.0f;
        [SerializeField] private float _areaHeight = 15.0f;
        [SerializeField] private Vector3 _adjustPosition;
        [SerializeField] private Vector3 _adjustScale;
        [SerializeField] private int _meshCount = 512;
        [SerializeField] private float _rotationAngleDegrees;

        private Matrix4x4[] _matrices;
        private List<Vector3> _positions;

        private void Start()
        {
            _positions = GenerateCoordinates(
                _areaWidth,
                _areaHeight,
                _meshCount,
                transform.position,
                _rotationAngleDegrees);

            _matrices = new Matrix4x4[_positions.Count];

            for (var i = 0; i < _positions.Count; i++)
            {
                var pos = _positions[i] * Random.Range(0.99f, 1.01f);
                var meshPosition = new Vector3(
                    pos.x + _adjustPosition.x,
                    _positions[i].y + _adjustPosition.y,
                    pos.z + _adjustPosition.z);

                _matrices[i % _meshCount] =
                    Matrix4x4.TRS(meshPosition, Quaternion.identity, _adjustScale);
            }
        }


        List<Vector3> GenerateCoordinates(
            float width,
            float height,
            int totalCoordinates,
            Vector3 center,
            float rotationAngleDegrees)
        {
            var coordinateList = new List<Vector3>();
            var rowCount = Mathf.FloorToInt(Mathf.Sqrt(totalCoordinates * (width / height)));
            var columnCount = totalCoordinates / rowCount;

            var spacingX = width / rowCount;
            var spacingZ = height / columnCount;

            var rotationAngleRadians = rotationAngleDegrees * Mathf.Deg2Rad;

            for (var col = 0; col < columnCount; col++)
            {
                for (var row = 0; row < rowCount; row++)
                {
                    var x = row * spacingX - width / 2 + center.x;
                    var z = col * spacingZ - height / 2 + center.z;

                    var pos = RotatePoint(new Vector3(x, center.y, z), center, rotationAngleRadians);
                    coordinateList.Add(pos);

                    if (coordinateList.Count >= totalCoordinates)
                        return coordinateList;
                }
            }

            return coordinateList;
        }

        Vector3 RotatePoint(Vector3 point, Vector3 center, float angleRadians)
        {
            var cosTheta = Mathf.Cos(angleRadians);
            var sinTheta = Mathf.Sin(angleRadians);

            var rotatedX = cosTheta * (point.x - center.x) - sinTheta * (point.z - center.z) + center.x;
            var rotatedZ = sinTheta * (point.x - center.x) + cosTheta * (point.z - center.z) + center.z;

            return new Vector3(rotatedX, point.y, rotatedZ);
        }

        private void Update()
        {
            Graphics.DrawMeshInstanced(_mesh, 0, _material, _matrices, _positions.Count);
        }
    }
}